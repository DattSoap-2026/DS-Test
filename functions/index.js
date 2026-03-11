/**
 * DattSoap ERP - Server Side Logic
 * Handles Inventory Management using Event-Driven Architecture.
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const FieldPath = admin.firestore.FieldPath;

const NOTIFICATION_EVENTS_COLLECTION = "notification_events";
const ADMIN_ROLES = ["Admin", "Owner"];
const MAX_WHERE_IN = 10;
const MAX_MULTICAST_TOKENS = 500;
const PUSH_LOCK_TTL_MS = 2 * 60 * 1000;

/**
 * Returns trimmed non-empty string array.
 * @param {*} raw
 * @return {string[]}
 */
function toStringArray(raw) {
  if (!Array.isArray(raw)) return [];
  return raw
      .filter((value) => typeof value === "string")
      .map((value) => value.trim())
      .filter((value) => value.length > 0);
}

/**
 * Splits array into chunks.
 * @param {Array<*>} list
 * @param {number} size
 * @return {Array<Array<*>>}
 */
function chunk(list, size) {
  const out = [];
  for (let i = 0; i < list.length; i += size) {
    out.push(list.slice(i, i + size));
  }
  return out;
}

/**
 * Normalizes role label for loose matching.
 * @param {string} role
 * @return {string}
 */
function normalizeRole(role) {
  return String(role || "")
      .trim()
      .replace(/[_\-\s]/g, "")
      .toLowerCase();
}

/**
 * Canonical role labels used in users collection.
 * @type {Map<string, string>}
 */
const ROLE_CANONICAL = new Map([
  ["owner", "Owner"],
  ["admin", "Admin"],
  ["productionmanager", "Production Manager"],
  ["salesmanager", "Sales Manager"],
  ["accountant", "Accountant"],
  ["dispatchmanager", "Dispatch Manager"],
  ["bhattisupervisor", "Bhatti Supervisor"],
  ["driver", "Driver"],
  ["salesman", "Salesman"],
  ["gatekeeper", "Gate Keeper"],
  ["storeincharge", "Store Incharge"],
  ["productionsupervisor", "Production Supervisor"],
  ["fuelincharge", "Fuel Incharge"],
  ["vehiclemaintenancemanager", "Vehicle Maintenance Manager"],
  ["dealermanager", "Dealer Manager"],
]);

/**
 * Converts role input into canonical display labels.
 * @param {string[]} roles
 * @return {string[]}
 */
function canonicalizeRoles(roles) {
  const out = new Set();
  for (const rawRole of roles) {
    const normalized = normalizeRole(rawRole);
    const canonical = ROLE_CANONICAL.get(normalized);
    if (canonical) {
      out.add(canonical);
    } else if (String(rawRole || "").trim().length > 0) {
      out.add(String(rawRole).trim());
    }
  }
  return Array.from(out);
}

/**
 * Checks if user document should receive push notifications.
 * @param {Record<string, *>} userData
 * @return {boolean}
 */
function isPushEligibleUser(userData) {
  if (!userData || typeof userData !== "object") return false;
  if (userData.isActive === false) return false;
  const status = String(userData.status || "").trim().toLowerCase();
  if (status === "inactive" || status === "blocked") return false;
  return true;
}

/**
 * Adds fcm token from user doc to recipient map.
 * @param {admin.firestore.QueryDocumentSnapshot<
 *   admin.firestore.DocumentData>} userDoc
 * @param {Map<string, Record<string, *>>} tokenRecipients
 * @param {string} reason
 */
function addTokenFromUserDoc(userDoc, tokenRecipients, reason) {
  const data = userDoc.data() || {};
  if (!isPushEligibleUser(data)) return;

  const token = typeof data.fcmToken === "string" ? data.fcmToken.trim() : "";
  if (!token) return;
  if (tokenRecipients.has(token)) return;

  tokenRecipients.set(token, {
    userDocId: userDoc.id,
    userId: typeof data.id === "string" ? data.id : "",
    role: typeof data.role === "string" ? data.role : "",
    reason,
  });
}

/**
 * Collect recipient tokens by target user ids.
 * Supports docId, users.id and users.fcmTokenUserId lookups.
 * @param {string[]} targetUserIds
 * @param {Map<string, Record<string, *>>} tokenRecipients
 */
async function collectRecipientsByUserIds(targetUserIds, tokenRecipients) {
  if (targetUserIds.length === 0) return;

  const ids = Array.from(new Set(targetUserIds));
  const idChunks = chunk(ids, MAX_WHERE_IN);
  const usersRef = db.collection("users");

  for (const part of idChunks) {
    const [byDocId, byUserId, byTokenUserId] = await Promise.all([
      usersRef.where(FieldPath.documentId(), "in", part).get(),
      usersRef.where("id", "in", part).get(),
      usersRef.where("fcmTokenUserId", "in", part).get(),
    ]);

    byDocId.forEach((doc) => addTokenFromUserDoc(doc, tokenRecipients, "docId"));
    byUserId.forEach((doc) => addTokenFromUserDoc(doc, tokenRecipients, "userId"));
    byTokenUserId.forEach((doc) => {
      addTokenFromUserDoc(doc, tokenRecipients, "fcmTokenUserId");
    });
  }
}

/**
 * Collect recipient tokens by target role labels.
 * @param {string[]} targetRoles
 * @param {Map<string, Record<string, *>>} tokenRecipients
 */
async function collectRecipientsByRoles(targetRoles, tokenRecipients) {
  if (targetRoles.length === 0) return;

  const roles = Array.from(new Set(targetRoles));
  const roleChunks = chunk(roles, MAX_WHERE_IN);
  const usersRef = db.collection("users");

  for (const part of roleChunks) {
    const snap = await usersRef.where("role", "in", part).get();
    snap.forEach((doc) => addTokenFromUserDoc(doc, tokenRecipients, "role"));
  }
}

/**
 * Converts event data payload values to FCM-safe strings.
 * @param {Record<string, *>} eventData
 * @param {string} eventId
 * @param {string} eventType
 * @param {string} route
 * @param {boolean} forceSound
 * @return {Record<string, string>}
 */
function buildStringDataPayload(eventData, eventId, eventType, route, forceSound) {
  const payload = {
    eventId,
    eventType,
    route,
    forceSound: forceSound ? "true" : "false",
  };

  if (eventData && typeof eventData === "object") {
    for (const [key, value] of Object.entries(eventData)) {
      if (value === null || value === undefined) continue;
      if (typeof value === "string") {
        payload[`data_${key}`] = value;
      } else if (
        typeof value === "number" ||
        typeof value === "boolean"
      ) {
        payload[`data_${key}`] = String(value);
      }
    }
    payload.dataJson = JSON.stringify(eventData);
  }

  return payload;
}

/**
 * Sends FCM notifications in multicast batches.
 * @param {string[]} tokens
 * @param {{title: string, body: string}} notification
 * @param {Record<string, string>} dataPayload
 * @param {boolean} forceSound
 * @return {Promise<{successCount: number, failureCount: number,
 * failed: Array<Record<string, string>>}>}
 */
async function sendMulticast(tokens, notification, dataPayload, forceSound) {
  let successCount = 0;
  let failureCount = 0;
  const failed = [];

  const tokenChunks = chunk(tokens, MAX_MULTICAST_TOKENS);
  for (const tokenChunk of tokenChunks) {
    const message = {
      tokens: tokenChunk,
      notification,
      data: dataPayload,
      android: {
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
          sound: forceSound ? "dattsoap_notification" : undefined,
          defaultSound: !forceSound,
        },
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
        payload: {
          aps: {
            sound: forceSound ? "dattsoap_notification.aiff" : "default",
            contentAvailable: true,
          },
        },
      },
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    successCount += response.successCount;
    failureCount += response.failureCount;

    response.responses.forEach((item, index) => {
      if (item.success) return;
      failed.push({
        token: tokenChunk[index],
        code: item.error && item.error.code ? item.error.code : "unknown",
        message: item.error && item.error.message ?
          item.error.message : "unknown",
      });
    });
  }

  return {successCount, failureCount, failed};
}

/**
 * Builds compact failure summary without exposing FCM tokens.
 * @param {Array<Record<string, string>>} failed
 * @return {Record<string, *>}
 */
function buildFailureSummary(failed) {
  const countsByCode = {};
  failed.forEach((entry) => {
    const code = entry.code || "unknown";
    countsByCode[code] = (countsByCode[code] || 0) + 1;
  });

  return {
    total: failed.length,
    countsByCode,
    samples: failed.slice(0, 10).map((entry) => ({
      code: entry.code || "unknown",
      message: entry.message || "unknown",
    })),
  };
}

/**
 * Clears permanently invalid FCM tokens from users collection.
 * @param {Array<Record<string, string>>} failed
 */
async function cleanupInvalidTokens(failed) {
  const invalidCodes = new Set([
    "messaging/invalid-registration-token",
    "messaging/registration-token-not-registered",
  ]);

  const invalidTokens = Array.from(new Set(
      failed
          .filter((entry) => invalidCodes.has(entry.code))
          .map((entry) => entry.token)
          .filter((token) => typeof token === "string" && token.trim().length > 0),
  ));

  if (invalidTokens.length === 0) return;

  const tokenChunks = chunk(invalidTokens, MAX_WHERE_IN);
  const usersRef = db.collection("users");

  for (const part of tokenChunks) {
    const snap = await usersRef.where("fcmToken", "in", part).get();
    if (snap.empty) continue;

    const batch = db.batch();
    snap.docs.forEach((doc) => {
      batch.set(doc.ref, {
        fcmToken: FieldValue.delete(),
        fcmTokenUpdatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
    });
    await batch.commit();
  }
}

/**
 * Claims dispatch lock and returns event payload if dispatch should proceed.
 * @param {admin.firestore.DocumentReference} eventRef
 * @param {string} source
 * @param {string} requestedBy
 * @return {Promise<{proceed: boolean, reason: string, eventData: Record<string, *>}>}
 */
async function claimPushDispatch(eventRef, source, requestedBy) {
  return await db.runTransaction(async (transaction) => {
    const snap = await transaction.get(eventRef);
    if (!snap.exists) {
      throw new Error("notification_event_not_found");
    }

    const eventData = snap.data() || {};
    const state = eventData.pushDispatch || {};
    if (state.status === "completed") {
      return {
        proceed: false,
        reason: "already_completed",
        eventData,
      };
    }

    const lockedAt = state.lockedAt && typeof state.lockedAt.toDate === "function" ?
      state.lockedAt.toDate() : null;
    const lockedAtMs = Number(state.lockedAtMs) || 0;
    const lockIsFresh = (lockedAt &&
      (Date.now() - lockedAt.getTime()) < PUSH_LOCK_TTL_MS) ||
      (lockedAtMs > 0 && (Date.now() - lockedAtMs) < PUSH_LOCK_TTL_MS);
    if (state.status === "processing" && lockIsFresh) {
      return {
        proceed: false,
        reason: "already_processing",
        eventData,
      };
    }

    transaction.set(eventRef, {
      pushDispatch: {
        ...state,
        status: "processing",
        source,
        requestedBy: requestedBy || null,
        attempts: (Number(state.attempts) || 0) + 1,
        lockedAtMs: Date.now(),
        lockedAt: FieldValue.serverTimestamp(),
      },
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});

    return {
      proceed: true,
      reason: "claimed",
      eventData,
    };
  });
}

/**
 * Dispatches push notification for one notification event document.
 * @param {admin.firestore.DocumentReference} eventRef
 * @param {string} eventId
 * @param {string} source
 * @param {string} requestedBy
 * @return {Promise<Record<string, *>>}
 */
async function dispatchEventPush(eventRef, eventId, source, requestedBy) {
  const claim = await claimPushDispatch(eventRef, source, requestedBy);
  if (!claim.proceed) {
    return {
      ok: true,
      skipped: true,
      reason: claim.reason,
      eventId,
    };
  }

  const eventData = claim.eventData || {};
  const title = typeof eventData.title === "string" && eventData.title.trim() ?
    eventData.title.trim() : "DattSoap";
  const body = typeof eventData.body === "string" && eventData.body.trim() ?
    eventData.body.trim() : "New update available";
  const eventType = typeof eventData.eventType === "string" &&
      eventData.eventType.trim() ?
    eventData.eventType.trim() : "general";
  const route = typeof eventData.route === "string" ? eventData.route.trim() : "";
  const forceSound = eventData.forceSound !== false;

  const targetUserIds = toStringArray(eventData.targetUserIds);
  const targetRoles = canonicalizeRoles(toStringArray(eventData.targetRoles));
  const allRoleTargets = canonicalizeRoles([...targetRoles, ...ADMIN_ROLES]);

  const tokenRecipients = new Map();
  await Promise.all([
    collectRecipientsByUserIds(targetUserIds, tokenRecipients),
    collectRecipientsByRoles(allRoleTargets, tokenRecipients),
  ]);

  const tokens = Array.from(tokenRecipients.keys());
  if (tokens.length === 0) {
    await eventRef.set({
      pushDispatch: {
        status: "completed",
        source,
        requestedBy: requestedBy || null,
        completedAt: FieldValue.serverTimestamp(),
        recipientCount: 0,
        successCount: 0,
        failureCount: 0,
        reason: "no_target_tokens",
      },
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});

    return {
      ok: true,
      eventId,
      recipientCount: 0,
      successCount: 0,
      failureCount: 0,
      reason: "no_target_tokens",
    };
  }

  try {
    const dataPayload = buildStringDataPayload(
        eventData.data || {},
        eventId,
        eventType,
        route,
        forceSound,
    );
    const sendResult = await sendMulticast(
        tokens,
        {title, body},
        dataPayload,
        forceSound,
    );
    await cleanupInvalidTokens(sendResult.failed);

    await eventRef.set({
      pushDispatch: {
        status: "completed",
        source,
        requestedBy: requestedBy || null,
        completedAt: FieldValue.serverTimestamp(),
        recipientCount: tokens.length,
        successCount: sendResult.successCount,
        failureCount: sendResult.failureCount,
        failureSummary: buildFailureSummary(sendResult.failed),
      },
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});

    return {
      ok: true,
      eventId,
      recipientCount: tokens.length,
      successCount: sendResult.successCount,
      failureCount: sendResult.failureCount,
    };
  } catch (error) {
    await eventRef.set({
      pushDispatch: {
        status: "failed",
        source,
        requestedBy: requestedBy || null,
        failedAt: FieldValue.serverTimestamp(),
        error: error && error.message ? String(error.message) : String(error),
      },
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    throw error;
  }
}

// --- 1. HANDLE SALES (Decrement Stock) ---
exports.onSaleCreated = functions.firestore
    .document("sales/{saleId}")
    .onCreate(async (snap, context) => {
        const sale = snap.data();
        const saleId = context.params.saleId;
        const items = sale.items || [];

        if (items.length === 0) {
            console.log(`Sale ${saleId} has no items.`);
            return null;
        }

        console.log(`Processing Sale ${saleId} - ${items.length} items.`);

        try {
            await db.runTransaction(async (transaction) => {
                for (const item of items) {
                    const productId = item.productId;
                    const quantity = Number(item.quantity) || 0;

                    if (!productId || quantity <= 0) continue;

                    const productRef = db.collection("products").doc(productId);
                    const productDoc = await transaction.get(productRef);

                    if (!productDoc.exists) {
                        console.warn(`Product ${productId} not found for Sale ${saleId}`);
                        continue;
                    }

                    const currentStock = Number(productDoc.data().stock) || 0;
                    let newStock = currentStock - quantity;

                    if (newStock < 0) {
                        console.error(`STOCK WARNING: Product ${productId} is negative! (${newStock})`);
                    }

                    transaction.update(productRef, {
                        stock: newStock,
                        updatedAt: new Date().toISOString(),
                    });

                    // Write stock_ledger audit entry for this sale item
                    const ledgerRef = db.collection("stock_ledger").doc();
                    transaction.set(ledgerRef, {
                        id: ledgerRef.id,
                        productId,
                        warehouseId: sale.warehouseId || "main",
                        transactionDate: FieldValue.serverTimestamp(),
                        transactionType: "OUT",
                        referenceId: saleId,
                        quantityChange: -quantity,
                        runningBalance: newStock,
                        unit: item.unit || "Pcs",
                        performedBy: sale.salesmanId || "system",
                        notes: `Sale: ${saleId}`,
                        createdAt: FieldValue.serverTimestamp(),
                    });
                }
            });
            console.log(`Sale ${saleId} stock processed successfully.`);
        } catch (e) {
            console.error(`Transaction failure for Sale ${saleId}:`, e);
        }
    });

// --- 2. HANDLE RETURNS (Increment Stock) ---
// Standard returns go back to Main Stock (good stock assumed unless flagged)
exports.onReturnCreated = functions.firestore
    .document("returns/{returnId}")
    .onCreate(async (snap, context) => {
        const returnData = snap.data();
        const returnId = context.params.returnId;
        const items = returnData.items || [];

        if (items.length === 0) return null;

        console.log(`Processing Return ${returnId} - ${items.length} items.`);

        try {
            await db.runTransaction(async (transaction) => {
                for (const item of items) {
                    const productId = item.productId;
                    const quantity = Number(item.quantity) || 0;

                    if (!productId || quantity <= 0) continue;

                    const productRef = db.collection("products").doc(productId);
                    const productDoc = await transaction.get(productRef);

                    if (!productDoc.exists) continue;

                    const currentStock = Number(productDoc.data().stock) || 0;
                    const newStock = currentStock + quantity;

                    transaction.update(productRef, {
                        stock: newStock,
                        updatedAt: new Date().toISOString(),
                    });

                    // Write stock_ledger audit entry for this return item
                    const ledgerRef = db.collection("stock_ledger").doc();
                    transaction.set(ledgerRef, {
                        id: ledgerRef.id,
                        productId,
                        warehouseId: returnData.warehouseId || "main",
                        transactionDate: FieldValue.serverTimestamp(),
                        transactionType: "IN",
                        referenceId: returnId,
                        quantityChange: quantity,
                        runningBalance: newStock,
                        unit: item.unit || "Pcs",
                        performedBy: returnData.salesmanId || returnData.dealerId || "system",
                        notes: `Return: ${returnId}`,
                        createdAt: FieldValue.serverTimestamp(),
                    });
                }
            });
        } catch (e) {
            console.error(`Transaction failure for Return ${returnId}:`, e);
        }
    });
// --- 3. HANDLE PRODUCTION (Increment Stock) ---
// production_entries schema: { items: [{productId, totalBatchQuantity, unit}], createdBy }
exports.onProductionCreated = functions.firestore
    .document("production_entries/{prodId}")
    .onCreate(async (snap, context) => {
        const prodData = snap.data();
        const prodId = context.params.prodId;
        const items = prodData.items || [];

        if (items.length === 0) {
            console.log(`Production entry ${prodId} has no items.`);
            return null;
        }

        console.log(`Processing Production ${prodId} - ${items.length} items.`);

        try {
            await db.runTransaction(async (transaction) => {
                for (const item of items) {
                    const productId = item.productId;
                    const quantity = Number(item.totalBatchQuantity) || 0;

                    if (!productId || quantity <= 0) continue;

                    const productRef = db.collection("products").doc(productId);
                    const productDoc = await transaction.get(productRef);

                    if (!productDoc.exists) {
                        console.warn(`Product ${productId} not found for Production ${prodId}`);
                        continue;
                    }

                    const currentStock = Number(productDoc.data().stock) || 0;
                    const newStock = currentStock + quantity;

                    transaction.update(productRef, {
                        stock: newStock,
                        updatedAt: new Date().toISOString(),
                    });

                    // Write stock_ledger audit entry for this production item
                    const ledgerRef = db.collection("stock_ledger").doc();
                    transaction.set(ledgerRef, {
                        id: ledgerRef.id,
                        productId,
                        warehouseId: prodData.warehouseId || "main",
                        transactionDate: FieldValue.serverTimestamp(),
                        transactionType: "IN",
                        referenceId: prodId,
                        quantityChange: quantity,
                        runningBalance: newStock,
                        unit: item.unit || "Pcs",
                        performedBy: prodData.createdBy || "system",
                        notes: `Production: ${prodId}`,
                        createdAt: FieldValue.serverTimestamp(),
                    });
                }
            });
            console.log(`Production ${prodId} stock processed successfully.`);
        } catch (e) {
            console.error(`Transaction failure for Production ${prodId}:`, e);
        }
    });

// --- 4. DAILY CLEANUP / ALERTS (Scheduled) ---
// Optional: Check low stock daily

/**
 * Callable trigger for sending push notification from notification_events doc.
 * Expected payload: { eventId: string }
 */
exports.dispatchNotificationEvent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required to dispatch notification event.",
    );
  }

  const eventId = typeof data?.eventId === "string" ? data.eventId.trim() : "";
  if (!eventId) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "eventId is required.",
    );
  }

  const eventRef = db.collection(NOTIFICATION_EVENTS_COLLECTION).doc(eventId);
  const snap = await eventRef.get();
  if (!snap.exists) {
    throw new functions.https.HttpsError(
        "not-found",
        "notification event not found.",
    );
  }

  try {
    return await dispatchEventPush(
        eventRef,
        eventId,
        "callable",
        context.auth.uid,
    );
  } catch (error) {
    console.error(`dispatchNotificationEvent failed for ${eventId}:`, error);
    throw new functions.https.HttpsError(
        "internal",
        "Failed to dispatch notification event.",
    );
  }
});

/**
 * Fallback server-side trigger: dispatch push as soon as event is created.
 * This guarantees delivery even if client callable is skipped (offline cases).
 */
exports.onNotificationEventCreated = functions.firestore
    .document(`${NOTIFICATION_EVENTS_COLLECTION}/{eventId}`)
    .onCreate(async (snap, context) => {
      const eventId = context.params.eventId;
      try {
        await dispatchEventPush(snap.ref, eventId, "firestore_on_create", "system");
      } catch (error) {
        console.error(`onNotificationEventCreated failed for ${eventId}:`, error);
      }
      return null;
    });

// ==========================================================================
// TASK-01: Atomic Dispatch (callable) — Windows atomicity fix
// Called by Flutter client when dispatching van stock to avoid
// read-then-write race on Windows where Firestore transactions are
// unreliable via the C++ SDK.
// ==========================================================================
exports.atomicDispatch = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required for atomic dispatch.",
    );
  }

  const dispatchId = typeof data?.dispatchId === "string" ?
    data.dispatchId.trim() : "";
  const items = Array.isArray(data?.items) ? data.items : [];
  const salesmanId = typeof data?.salesmanId === "string" ?
    data.salesmanId.trim() : "";
  const dispatchData = data?.dispatchData || {};

  if (!dispatchId) {
    throw new functions.https.HttpsError(
        "invalid-argument", "dispatchId is required.");
  }
  if (items.length === 0) {
    throw new functions.https.HttpsError(
        "invalid-argument", "items array is required and must not be empty.");
  }
  if (!salesmanId) {
    throw new functions.https.HttpsError(
        "invalid-argument", "salesmanId is required.");
  }

  console.log(`atomicDispatch: ${dispatchId}, ${items.length} items, ` +
    `salesman=${salesmanId}, caller=${context.auth.uid}`);

  await db.runTransaction(async (txn) => {
    // 1. Idempotency check — skip if dispatch already written
    const dispatchRef = db.collection("dispatches").doc(dispatchId);
    const existingSnap = await txn.get(dispatchRef);
    if (existingSnap.exists) {
      console.log(`atomicDispatch: ${dispatchId} already exists, skipping.`);
      return;
    }

    // 2. Read + validate all product stocks FIRST (Firestore requires
    //    all reads before writes in a transaction)
    const productRefs = [];
    const productSnaps = [];
    for (const item of items) {
      const pid = typeof item.productId === "string" ?
        item.productId.trim() : "";
      if (!pid) continue;
      const ref = db.collection("products").doc(pid);
      productRefs.push({ref, item});
      productSnaps.push(await txn.get(ref));
    }

    // 3. Validate stock availability
    for (let i = 0; i < productRefs.length; i++) {
      const snap = productSnaps[i];
      const {item} = productRefs[i];
      const qty = Number(item.quantity) || 0;
      if (qty <= 0) continue;

      if (!snap.exists) {
        throw new functions.https.HttpsError(
            "not-found",
            `Product ${item.productId} not found.`,
        );
      }

      const currentStock = Number(snap.data().stock) || 0;
      if (currentStock - qty < -1e-9) {
        throw new functions.https.HttpsError(
            "failed-precondition",
            `Insufficient stock for ${item.productId}. ` +
            `Available: ${currentStock}, Requested: ${qty}`,
        );
      }
    }

    // 4. Apply writes: deduct warehouse stock, create movement records
    const now = new Date().toISOString();
    for (let i = 0; i < productRefs.length; i++) {
      const snap = productSnaps[i];
      const {ref, item} = productRefs[i];
      const qty = Number(item.quantity) || 0;
      if (qty <= 0 || !snap.exists) continue;

      const currentStock = Number(snap.data().stock) || 0;
      const newStock = currentStock - qty;

      // Deduct warehouse stock
      txn.update(ref, {
        stock: newStock,
        updatedAt: now,
      });

      // Create stock_movement record
      const movementRef = db.collection("stock_movements").doc();
      txn.set(movementRef, {
        id: movementRef.id,
        productId: item.productId,
        type: "DISPATCH",
        quantity: -qty,
        referenceId: dispatchId,
        referenceType: "dispatch",
        warehouseId: dispatchData.warehouseId || "main",
        performedBy: context.auth.uid,
        salesmanId: salesmanId,
        notes: `Dispatch: ${dispatchId}`,
        createdAt: FieldValue.serverTimestamp(),
      });

      // Create stock_ledger audit entry
      const ledgerRef = db.collection("stock_ledger").doc();
      txn.set(ledgerRef, {
        id: ledgerRef.id,
        productId: item.productId,
        warehouseId: dispatchData.warehouseId || "main",
        transactionDate: FieldValue.serverTimestamp(),
        transactionType: "OUT",
        referenceId: dispatchId,
        quantityChange: -qty,
        runningBalance: newStock,
        unit: item.unit || "Pcs",
        performedBy: context.auth.uid,
        notes: `Dispatch: ${dispatchId}`,
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    // 5. Write the dispatch document itself
    txn.set(dispatchRef, {
      ...dispatchData,
      id: dispatchId,
      salesmanId,
      isSynced: true,
      syncedAt: FieldValue.serverTimestamp(),
      syncedVia: "atomicDispatch",
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  console.log(`atomicDispatch: ${dispatchId} completed successfully.`);
  return {success: true, dispatchId};
});

// ==========================================================================
// TASK-02: Atomic Production Batch (callable) — Production atomicity fix
// Ensures raw material deduction + finished goods crediting happen in one
// transaction, preventing partial state where materials are consumed but
// finished goods aren't credited (or vice versa).
// ==========================================================================
exports.atomicProductionBatch = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required for atomic production batch.",
    );
  }

  const productionLogId = typeof data?.productionLogId === "string" ?
    data.productionLogId.trim() : "";
  const rawMaterialDeductions = Array.isArray(data?.rawMaterialDeductions) ?
    data.rawMaterialDeductions : [];
  const finishedGoodsCredits = Array.isArray(data?.finishedGoodsCredits) ?
    data.finishedGoodsCredits : [];
  const logData = data?.logData || {};

  if (!productionLogId) {
    throw new functions.https.HttpsError(
        "invalid-argument", "productionLogId is required.");
  }
  if (rawMaterialDeductions.length === 0 && finishedGoodsCredits.length === 0) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "At least one raw material deduction or finished goods credit required.");
  }

  console.log(`atomicProductionBatch: ${productionLogId}, ` +
    `${rawMaterialDeductions.length} raw materials, ` +
    `${finishedGoodsCredits.length} finished goods, ` +
    `caller=${context.auth.uid}`);

  await db.runTransaction(async (txn) => {
    // 1. Idempotency check
    const logRef = db.collection("production_entries").doc(productionLogId);
    const existingSnap = await txn.get(logRef);
    if (existingSnap.exists) {
      console.log(`atomicProductionBatch: ${productionLogId} already exists.`);
      return;
    }

    // 2. Read ALL product documents first (reads before writes)
    const allItems = [
      ...rawMaterialDeductions.map((rm) => ({...rm, type: "deduct"})),
      ...finishedGoodsCredits.map((fg) => ({...fg, type: "credit"})),
    ];
    const productReads = [];
    for (const item of allItems) {
      const pid = typeof item.productId === "string" ?
        item.productId.trim() : "";
      if (!pid) continue;
      const ref = db.collection("products").doc(pid);
      const snap = await txn.get(ref);
      productReads.push({ref, snap, item});
    }

    // 3. Validate raw material stock levels
    for (const {snap, item} of productReads) {
      if (item.type !== "deduct") continue;
      const qty = Number(item.quantity) || 0;
      if (qty <= 0) continue;

      if (!snap.exists) {
        throw new functions.https.HttpsError(
            "not-found",
            `Raw material ${item.productId} not found.`,
        );
      }

      const currentStock = Number(snap.data().stock) || 0;
      if (currentStock - qty < -1e-9) {
        throw new functions.https.HttpsError(
            "failed-precondition",
            `Insufficient raw material: ${item.productId}. ` +
            `Available: ${currentStock}, Requested: ${qty}`,
        );
      }
    }

    // 4. Apply writes
    const now = new Date().toISOString();
    for (const {ref, snap, item} of productReads) {
      const qty = Number(item.quantity) || 0;
      if (qty <= 0) continue;

      const currentStock = snap.exists ? (Number(snap.data().stock) || 0) : 0;

      if (item.type === "deduct") {
        // Deduct raw material
        const newStock = currentStock - qty;
        txn.update(ref, {stock: newStock, updatedAt: now});

        const movementRef = db.collection("stock_movements").doc();
        txn.set(movementRef, {
          id: movementRef.id,
          productId: item.productId,
          type: "PRODUCTION_CONSUMPTION",
          quantity: -qty,
          referenceId: productionLogId,
          referenceType: "production",
          warehouseId: logData.warehouseId || "main",
          performedBy: context.auth.uid,
          notes: `Production consumption: ${productionLogId}`,
          createdAt: FieldValue.serverTimestamp(),
        });
      } else {
        // Credit finished goods
        const newStock = currentStock + qty;
        if (snap.exists) {
          txn.update(ref, {stock: newStock, updatedAt: now});
        } else {
          txn.set(ref, {
            id: item.productId,
            stock: qty,
            updatedAt: now,
            createdAt: FieldValue.serverTimestamp(),
          });
        }

        const movementRef = db.collection("stock_movements").doc();
        txn.set(movementRef, {
          id: movementRef.id,
          productId: item.productId,
          type: "PRODUCTION_OUTPUT",
          quantity: qty,
          referenceId: productionLogId,
          referenceType: "production",
          warehouseId: logData.warehouseId || "main",
          performedBy: context.auth.uid,
          notes: `Production output: ${productionLogId}`,
          createdAt: FieldValue.serverTimestamp(),
        });
      }
    }

    // 5. Write the production log document
    txn.set(logRef, {
      ...logData,
      id: productionLogId,
      isSynced: true,
      syncedAt: FieldValue.serverTimestamp(),
      syncedVia: "atomicProductionBatch",
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  console.log(`atomicProductionBatch: ${productionLogId} completed.`);
  return {success: true, productionLogId};
});
