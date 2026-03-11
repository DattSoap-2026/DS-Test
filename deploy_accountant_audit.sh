#!/bin/bash

# Accountant Audit System - Deployment Script
# This script deploys the Firestore rules for Accountant audit system

echo "=========================================="
echo "  Accountant Audit System Deployment"
echo "=========================================="
echo ""

# Check if firebase CLI is installed
if ! command -v firebase &> /dev/null
then
    echo "❌ Firebase CLI not found!"
    echo "   Install: npm install -g firebase-tools"
    exit 1
fi

echo "✅ Firebase CLI found"
echo ""

# Check if logged in
echo "Checking Firebase authentication..."
firebase projects:list > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Not logged in to Firebase"
    echo "   Run: firebase login"
    exit 1
fi

echo "✅ Firebase authentication verified"
echo ""

# Show current project
echo "Current Firebase project:"
firebase use
echo ""

# Confirm deployment
read -p "Deploy Firestore rules? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "❌ Deployment cancelled"
    exit 1
fi

echo ""
echo "Deploying Firestore rules..."
echo ""

# Deploy rules
firebase deploy --only firestore:rules

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "  ✅ Deployment Successful!"
    echo "=========================================="
    echo ""
    echo "⏳ Wait 30-60 seconds for rules to propagate"
    echo ""
    echo "📋 Next Steps:"
    echo "   1. Wait 60 seconds"
    echo "   2. Login as Accountant (account@dattsoap.com)"
    echo "   3. Try creating a voucher"
    echo "   4. Verify no permission errors"
    echo "   5. Login as Admin"
    echo "   6. Check Audit Log screen"
    echo ""
    echo "📚 Documentation:"
    echo "   - ACCOUNTANT_AUDIT_COMPLETE.md"
    echo "   - ACCOUNTANT_AUDIT_QUICK_REF.md"
    echo "   - ACCOUNTANT_AUDIT_FLOW.md"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "  ❌ Deployment Failed!"
    echo "=========================================="
    echo ""
    echo "Troubleshooting:"
    echo "   1. Check Firebase project is correct"
    echo "   2. Verify firestore.rules file exists"
    echo "   3. Check Firebase permissions"
    echo "   4. Review error messages above"
    echo ""
    exit 1
fi
