# 🧪 Manual Testing Checklist - BotecoPro Navigation & Authentication

## Overview
This document provides a comprehensive manual testing checklist for the new authentication and navigation improvements in BotecoPro.

## Pre-Testing Setup

### Environment Setup
```bash
# Ensure Flutter is installed
flutter doctor

# Get dependencies
cd /path/to/BotecoPro
flutter pub get

# Build for web
flutter build web --release

# Serve locally
cd build/web
python3 -m http.server 8080
```

### Browser Setup
- Test in Chrome/Chromium (primary)
- Test in Firefox (secondary)
- Test in Safari (if available)
- Test on mobile device (responsive)

---

## Test Scenarios

### 1. Initial Load & Splash Screen

**Steps:**
1. Clear browser cache and local storage
2. Open `http://localhost:8080`
3. Observe splash screen

**Expected Results:**
- ✅ Boteco PRO logo displays
- ✅ Loading animation appears
- ✅ After ~2 seconds, redirects to Login page (first time)
- ✅ No console errors

**Pass/Fail:** [ ]

---

### 2. Login Page - UI Verification

**Steps:**
1. Observe login page elements

**Expected Results:**
- ✅ Boteco PRO logo at top
- ✅ Title "Boteco PRO" visible
- ✅ Subtitle "Gestão completa para seu bar" visible
- ✅ Email input field with placeholder
- ✅ Password input field with visibility toggle
- ✅ "Entrar" button
- ✅ Demo MVP information box
- ✅ All animations smooth
- ✅ Responsive layout (test resize)

**Pass/Fail:** [ ]

---

### 3. Login - Form Validation

**Test 3a: Empty Email**
1. Leave email field empty
2. Enter password "test123"
3. Click "Entrar"

**Expected:** 
- ✅ Shows error "Por favor, insira seu email"

**Pass/Fail:** [ ]

**Test 3b: Invalid Email**
1. Enter "notanemail" in email field
2. Enter password "test123"
3. Click "Entrar"

**Expected:**
- ✅ Shows error "Por favor, insira um email válido"

**Pass/Fail:** [ ]

**Test 3c: Empty Password**
1. Enter "test@example.com" in email
2. Leave password empty
3. Click "Entrar"

**Expected:**
- ✅ Shows error "Por favor, insira sua senha"

**Pass/Fail:** [ ]

**Test 3d: Short Password**
1. Enter "test@example.com" in email
2. Enter "123" in password
3. Click "Entrar"

**Expected:**
- ✅ Shows error "Senha deve ter no mínimo 4 caracteres"

**Pass/Fail:** [ ]

---

### 4. Login - Successful Authentication

**Steps:**
1. Enter valid email: `admin@boteco.com`
2. Enter valid password: `1234`
3. Click "Entrar"

**Expected Results:**
- ✅ Loading indicator appears briefly
- ✅ Navigates to Home/Dashboard
- ✅ URL changes to appropriate route
- ✅ No console errors

**Pass/Fail:** [ ]

---

### 5. Home Page - Post-Login

**Steps:**
1. After successful login, observe home page

**Expected Results:**
- ✅ Welcome message shows user name (e.g., "Bom dia, admin")
- ✅ Logout button (icon) in top-right of AppBar
- ✅ Dashboard KPIs display
- ✅ Menu cards visible
- ✅ Bottom navigation (mobile) or side rail (desktop) present
- ✅ All data loads correctly

**Pass/Fail:** [ ]

---

### 6. Navigation - Tab Switching

**Steps:**
1. Click each navigation tab/option:
   - Home (Início)
   - Mesas (Tables)
   - Produtos (Products)
   - Receitas (Recipes)
   - Produção (Production)

**Expected Results:**
- ✅ Each tab loads correctly
- ✅ Content displays for each section
- ✅ Tab indicator updates
- ✅ No blank pages
- ✅ No console errors

**Pass/Fail:** [ ]

---

### 7. Navigation - Detail Pages

**Test 7a: Suppliers Page**
1. From home, click "Fornecedores" card
2. Observe suppliers page
3. Click back button

**Expected:**
- ✅ Suppliers page loads
- ✅ CustomAppBar shows back button
- ✅ Back button returns to Home
- ✅ No blank page appears

**Pass/Fail:** [ ]

**Test 7b: Order Details**
1. Navigate to Mesas tab
2. Click on an occupied table
3. Observe order details
4. Click back button

**Expected:**
- ✅ Order details page loads
- ✅ Back button returns to Mesas page
- ✅ No blank page appears

**Pass/Fail:** [ ]

---

### 8. Browser Back Button - Web Specific

**Test 8a: Back from Detail Page**
1. Navigate: Home → Fornecedores
2. Press browser back button

**Expected:**
- ✅ Returns to Home
- ✅ No blank page
- ✅ App state preserved

**Pass/Fail:** [ ]

**Test 8b: Back from Secondary Tab**
1. Navigate to Produtos tab
2. Press browser back button

**Expected:**
- ✅ Returns to Home tab
- ✅ Navigation indicator updates
- ✅ No exit confirmation

**Pass/Fail:** [ ]

**Test 8c: Back from Home Tab**
1. Ensure on Home tab
2. Press browser back button

**Expected:**
- ✅ Shows "Sair do aplicativo?" dialog
- ✅ Options: "Cancelar" and "Sair"
- ✅ Cancelar keeps app open
- ✅ Sair closes/navigates away

**Pass/Fail:** [ ]

**Test 8d: Forward Button**
1. Navigate back as in 8b
2. Press browser forward button

**Expected:**
- ✅ Returns to previous tab
- ✅ State preserved

**Pass/Fail:** [ ]

---

### 9. Content Creation - Products

**Steps:**
1. Navigate to Produtos tab
2. Click floating action button (+ icon)
3. Fill product form:
   - Name: "Test Product"
   - Category: Select any
   - Price: 10.00
   - Stock: 50
4. Save product

**Expected Results:**
- ✅ Dialog opens
- ✅ Form accepts input
- ✅ Product saved successfully
- ✅ Product appears in list
- ✅ Can edit product
- ✅ Can delete product

**Pass/Fail:** [ ]

---

### 10. Content Creation - Tables

**Steps:**
1. Navigate to Mesas tab
2. Create/edit a table
3. Change table status
4. Create an order for table

**Expected Results:**
- ✅ All CRUD operations work
- ✅ Status updates reflected
- ✅ Order creation successful
- ✅ Data persists

**Pass/Fail:** [ ]

---

### 11. Logout Functionality

**Test 11a: Logout Confirmation**
1. From Home, click logout icon
2. Observe confirmation dialog

**Expected:**
- ✅ Dialog appears with title "Sair"
- ✅ Message asks for confirmation
- ✅ Two buttons: "Cancelar" and "Sair"

**Pass/Fail:** [ ]

**Test 11b: Cancel Logout**
1. Click logout icon
2. Click "Cancelar" in dialog

**Expected:**
- ✅ Dialog closes
- ✅ User remains logged in
- ✅ Stays on Home page

**Pass/Fail:** [ ]

**Test 11c: Confirm Logout**
1. Click logout icon
2. Click "Sair" in dialog

**Expected:**
- ✅ Dialog closes
- ✅ Navigates to Login page
- ✅ All routes cleared (can't go back to home)
- ✅ Session cleared

**Pass/Fail:** [ ]

---

### 12. Session Persistence

**Test 12a: Page Reload**
1. Login successfully
2. Navigate to any page
3. Press F5 (reload page)

**Expected:**
- ✅ Returns to splash screen
- ✅ Automatically redirects to Home (stays logged in)
- ✅ Data preserved

**Pass/Fail:** [ ]

**Test 12b: Close and Reopen Browser**
1. Login successfully
2. Close browser completely
3. Reopen and navigate to app

**Expected:**
- ✅ Splash screen shows
- ✅ Automatically logs in
- ✅ Goes to Home
- ✅ Session maintained

**Pass/Fail:** [ ]

**Test 12c: New Browser Tab**
1. Login in Tab 1
2. Open new tab
3. Navigate to app URL

**Expected:**
- ✅ New tab also shows logged-in state
- ✅ Shares session with Tab 1
- ✅ Both tabs functional

**Pass/Fail:** [ ]

---

### 13. Responsive Design

**Test 13a: Desktop Layout (>800px)**
1. Set browser width > 800px
2. Observe layout

**Expected:**
- ✅ Navigation Rail on left side
- ✅ Content expanded on right
- ✅ No bottom navigation
- ✅ All features accessible

**Pass/Fail:** [ ]

**Test 13b: Mobile Layout (<800px)**
1. Set browser width < 800px (or use mobile device)
2. Observe layout

**Expected:**
- ✅ No navigation rail
- ✅ Bottom navigation appears
- ✅ Content full width
- ✅ Touch-friendly

**Pass/Fail:** [ ]

**Test 13c: Tablet (600-800px)**
1. Set browser width 600-800px
2. Navigate and test features

**Expected:**
- ✅ Layout adapts smoothly
- ✅ All features work
- ✅ Bottom navigation shown

**Pass/Fail:** [ ]

---

### 14. Error Handling

**Test 14a: Network Offline (Simulated)**
1. Open DevTools
2. Go to Network tab
3. Select "Offline"
4. Try to login

**Expected:**
- ✅ App handles gracefully (no crash)
- ✅ Since no backend, login should still work (local only)
- ✅ Error message if needed

**Pass/Fail:** [ ]

---

### 15. Data Persistence

**Test 15a: Create Data and Reload**
1. Login
2. Create 2 products
3. Create 1 supplier
4. Reload page

**Expected:**
- ✅ All created data still present
- ✅ Data loads from localStorage
- ✅ No data loss

**Pass/Fail:** [ ]

**Test 15b: Clear Storage and Reload**
1. Login
2. Open DevTools → Application → Local Storage
3. Clear all for localhost
4. Reload page

**Expected:**
- ✅ Redirects to Login
- ✅ Must login again
- ✅ Initial sample data reloaded

**Pass/Fail:** [ ]

---

### 16. Console Errors

**Throughout all tests:**

**Expected:**
- ✅ No red errors in console
- ✅ No failed network requests (except expected)
- ✅ No React/Flutter warnings
- ✅ No deprecation warnings

**Pass/Fail:** [ ]

---

### 17. Accessibility (Optional)

**Test 17a: Keyboard Navigation**
1. Use Tab key to navigate form
2. Use Enter to submit

**Expected:**
- ✅ Can tab through all fields
- ✅ Focus indicators visible
- ✅ Enter submits form

**Pass/Fail:** [ ]

**Test 17b: Screen Reader (Optional)**
1. Enable screen reader
2. Navigate login page

**Expected:**
- ✅ Fields announced correctly
- ✅ Buttons labeled properly

**Pass/Fail:** [ ]

---

## Summary Report

### Total Tests: 30+
### Passed: ___
### Failed: ___
### Blocked: ___

### Critical Issues Found:
1. 
2. 
3. 

### Minor Issues Found:
1. 
2. 
3. 

### Notes:


### Screenshots Needed:
- [ ] Login page
- [ ] Home page with logout button
- [ ] Desktop layout with navigation rail
- [ ] Mobile layout with bottom nav
- [ ] Logout confirmation dialog
- [ ] Browser back button behavior
- [ ] Content creation (products page)

---

## Regression Testing

After fixes, re-run:
- [ ] All failed scenarios
- [ ] Related scenarios
- [ ] Core flows (login → navigate → logout)

---

**Tested By:** _______________
**Date:** _______________
**Browser:** _______________
**OS:** _______________
**Build Version:** _______________

---

## Quick Smoke Test (5 minutes)

For rapid verification:

1. [ ] Open app → Login page appears
2. [ ] Login with test@test.com / 1234 → Home loads
3. [ ] Click Mesas tab → Loads correctly
4. [ ] Click Produtos tab → Loads correctly
5. [ ] Press browser back → Returns to Home tab
6. [ ] Click logout → Confirmation shown
7. [ ] Confirm logout → Returns to Login
8. [ ] Reload page → Redirects to Login (logged out)
9. [ ] Login again → Works correctly
10. [ ] Resize window → Layout adapts

**All Pass?** [ ] Yes  [ ] No

If No, proceed with full testing checklist.
