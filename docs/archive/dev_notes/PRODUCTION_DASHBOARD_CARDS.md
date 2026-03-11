# Production Dashboard - Cards Quick Reference

##  Dashboard Layout Overview

```

 [Offline Indicator] (if offline)                

  7-Day Trend (Line Chart)                      
   

 Mobile: Full Width           Desktop: 2 Column  
    
  Today's Mix                Mix   Targets 
    
  Today's Targets                          
    

 Today's Production (Shift Cards)                
 Mobile: 1 Column            Desktop: 2x2 Grid  
    
  Morning Shift            Morning Evening 
    
  Evening Shift             Night   Daily  
             Total  
  Night Shift              
                       
  Daily Total                                 
                       

 Quick Stats (3 metrics row)                     

 Recent Logs (List of last 5 batches)            

 [Low Stock Alert] (if any items low)            

 Reports (Links to detailed reports)             

 Recent Batches (Full batch list)                

```

---

##  Card Details

### 1 7-Day Trend Card
```
 7-Day Trend 
                                               
  4                                           
                                           
  2                                      
                                       
  0_______________________                
   Fri Sat Sun Mon Tue Wed Thu                
                                               

```

**Data Source:** Firestore `production_batches`  
**Cache:** SQLite `production_trends` table  
**Metrics Shown:** Units produced per day  
**Offline:**  Yes (cached daily)  
**Update:** On refresh or daily reset  

---

### 2 Today's Mix Card
```
 Today's Mix 
                                               
   2450 units produced                        
                                               
   Product A          1200 units              
   Product B           900 units              
   Product C           350 units              
                                               

```

**Data Source:** Firestore `production_batches` (today)  
**Cache:** SQLite `production_summaries`  
**Metrics Shown:** 
- Total units
- Top 3 products by count
  
**Offline:**  Yes  
**Mobile Layout:** Stack vertically  
**Desktop Layout:** Side-by-side with Targets  

---

### 3 Today's Targets Card
```
 Today's Targets 
                                               
  Achievement            [92%]                
                                               
   92%                   
                                               
  Target: 2500    Done: 2300                  
                                               

```

**Data Source:** Firestore `production_targets` + batches  
**Cache:** SQLite `production_targets`  
**Metrics Shown:**
- Target units vs actual
- Achievement percentage
- Progress bar with color coding

**Color Coding:**
-  Red: <75% achievement
-  Orange: 75-99% achievement  
-  Green: 100% achievement

**Offline:**  Yes  

---

### 4 Recent Logs Card
```
 Recent Logs 
                                               
   BATCH-2026-089                    45 units 
    Gita 130g 10                              
                                               
   BATCH-2026-088                    50 units 
    Buzz 180g 10                              
                                               
   BATCH-2026-087                    40 units 
    Darbar M 130g 20                         
                                               

```

**Data Source:** Firestore `production_batches` (last 5)  
**Cache:** SQLite `production_logs`  
**Metrics Shown:**
- Batch number
- Product name
- Units produced

**Offline:**  Yes  
**Order:** Newest first  

---

### 5 Low Stock Alert Card
```
 Low Stock Alert 
                           [5 items]         

 Product        Stock     Status             

 Gita 130g x10  975 Bag   [In Stock]         
 Gita 200g x10  975 Box   [In Stock]         
 Gopi Bazaar    990 Bag   [In Stock]         
 Buzz 130g x10  1000 Bag  [In Stock]         
 Darbar M 130g  1000 Bag  [In Stock]         

```

**Data Source:** Firestore (inventory service)  
**Cache:** SQLite `low_stock_items`  
**Visibility:** Only if items below threshold  
**Layout:**
- Mobile: Stacked list format
- Desktop: Table format (3 columns)

**Offline:**  Yes  
**Refresh:** On pull-down refresh  

---

### 6 Offline Indicator (Banner)
```

  Offline Mode - Showing Cached Data        

```

**Trigger:** Network error during data fetch  
**Color:** Orange banner (#FF9800)  
**Icon:** WiFi off ()  
**Position:** Top of dashboard  
**Behavior:** Dismissible (auto-hides on refresh)  

---

##  Data Refresh Flow

### User Actions
```
Pull Down Refresh
        
  _loadDashboardData()
        

 Fetch from        Cache Result
 Firestore       

        
   Network Error?
             
  NO          YES
             
Update UI  Return Cache
             
  
        
   Update State
   Show Data
   Hide Spinner
```

---

##  Responsive Breakpoint

```
Screen Width < 600px = Mobile Mode
Screen Width  600px = Desktop Mode

Mobile Examples:
- iPhone SE: 375px
- iPhone 12: 390px
- iPhone Pro Max: 428px

Desktop Examples:
- iPad Mini: 768px
- iPad: 1024px
- Tablet: 1200px+
```

---

##  Cache Strategy (Offline-First)

```
First Load (Online):
1. Load from Firestore
2. Save to SQLite
3. Display data

Subsequent Loads (Online):
1. Load from Firestore
2. Update SQLite
3. Display latest data

Offline:
1. Try Firestore (fails)
2. Load from SQLite
3. Display cached data
4. Show offline banner

Auto-Cleanup:
- Runs every app start
- Deletes data older than 30 days
- Keeps recent data fresh
```

---

##  Key Features

| Feature | Mobile | Desktop | Offline |
|---------|--------|---------|---------|
| 7-Day Trend |  |  |  |
| Today's Mix |  |  |  |
| Targets Card |  |  |  |
| Recent Logs |  |  |  |
| Low Stock |  |  |  |
| Shift Cards |  |  |  |
| Responsive |  |  | - |
| Cached |  |  |  |
| Swipe Refresh |  |  |  |
| Offline Indicator |  |  |  |

---

##  Data Restrictions

**Only visible to:**
-  Admin users
-  Production Supervisors

**NOT visible to:**
-  Salesman
-  Store In-charge
-  Dispatch Users
-  Other roles

**Data isolated from:**
-  Sales dashboards
-  ERP metrics
-  Salesman earnings
-  Shop performance data

