const fs = require('fs');
const filePath = 'd:/Flutterdattsoap/DattSoap-main/DattSoap-main/functions/index.js';
let content = fs.readFileSync(filePath, 'utf8');

// Find the exact range for the onReturnCreated function
const startMarker = '// --- 2. HANDLE RETURNS (Increment Stock) ---';
const endMarker = '\n// --- 3. HANDLE PRODUCTION (Increment Stock) ---';

const startIdx = content.indexOf(startMarker);
const endIdx = content.indexOf(endMarker);

if (startIdx === -1 || endIdx === -1) {
    console.error('ERROR: Markers not found!');
    console.log('startIdx:', startIdx, 'endIdx:', endIdx);
    process.exit(1);
}

const before = content.substring(0, startIdx);
const after = content.substring(endIdx);

const newBlock = `// --- 2. HANDLE RETURNS (Increment Stock) ---
// Standard returns go back to Main Stock (good stock assumed unless flagged)
exports.onReturnCreated = functions.firestore
    .document("returns/{returnId}")
    .onCreate(async (snap, context) => {
        const returnData = snap.data();
        const returnId = context.params.returnId;
        const items = returnData.items || [];

        if (items.length === 0) return null;

        console.log(\`Processing Return \${returnId} - \${items.length} items.\`);

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
                        notes: \`Return: \${returnId}\`,
                        createdAt: FieldValue.serverTimestamp(),
                    });
                }
            });
        } catch (e) {
            console.error(\`Transaction failure for Return \${returnId}:\`, e);
        }
    });`;

const newContent = before + newBlock + after;
fs.writeFileSync(filePath, newContent, 'utf8');
console.log('SUCCESS: onReturnCreated patched with stock_ledger logging.');
