# DICE Security Monitoring Dashboard - Manual Setup Guide

**Version**: 1.0 - Complete Manual Setup  
**Created**: 2025-08-06 18:15 BST  
**Status**: ✅ **READY FOR IMPLEMENTATION**  
**Prerequisites**: ELK stack running, index patterns created, test data available

---

## 🎯 **OVERVIEW**

This guide provides detailed step-by-step instructions for creating the DICE Security Monitoring Dashboard manually through the Kibana UI. The foundation is complete and ready for dashboard creation.

### **✅ Foundation Status**

- [x] **Elasticsearch Index Templates**: Security template created
- [x] **Kibana Index Pattern**: `dice-security` pattern configured
- [x] **Test Data**: 15+ security test records available
- [x] **ELK Stack**: All services operational

### **📊 Available Data**

```bash
# Verify security data is available
curl -s "localhost:9200/dice-security-*/_search?size=5" | jq '.hits.hits'
```

---

## 🚀 **STEP-BY-STEP DASHBOARD CREATION**

### **Step 1: Access Kibana**

1. **Open Browser**: Navigate to <http://localhost:5601>
2. **Verify Access**: You should see the Kibana welcome page
3. **Check Index Pattern**: Go to Stack Management → Index Patterns → `dice-security`

### **Step 2: Create Authentication Events Timeline**

#### **2.1 Create Visualization**

1. **Navigate**: Go to Visualize Library
2. **Create Visualization**: Click "Create visualization"
3. **Select Type**: Choose "Line" chart
4. **Select Index Pattern**: Choose `dice-security`

#### **2.2 Configure Metrics**

1. **Y-axis (Metrics)**:
   - **Aggregation**: Count
   - **Custom Label**: "Authentication Events"

2. **X-axis (Buckets)**:
   - **Aggregation**: Date Histogram
   - **Field**: `timestamp`
   - **Interval**: 1 hour
   - **Custom Label**: "Time"

3. **Split Series**:
   - **Sub Aggregation**: Terms
   - **Field**: `action`
   - **Size**: 5
   - **Order By**: Count (desc)

#### **2.3 Configure Options**

1. **General**:
   - **Title**: "Authentication Events Timeline"
   - **Description**: "Real-time authentication events over time"

2. **Panel Settings**:
   - **Show Legend**: Yes
   - **Legend Position**: Right

#### **2.4 Save Visualization**

1. **Click**: "Save" button
2. **Name**: "Security Auth Events Timeline"
3. **Description**: "Authentication events timeline for security monitoring"

### **Step 3: Create OWASP Top 10 Distribution**

#### **3.1 Create Visualization**

1. **Create New Visualization**: Choose "Pie" chart
2. **Select Index Pattern**: Choose `dice-security`

#### **3.2 Configure Metrics**

1. **Slice Size**:
   - **Aggregation**: Count
   - **Custom Label**: "Security Events"

2. **Split Slices**:
   - **Aggregation**: Terms
   - **Field**: `owaspCategory`
   - **Size**: 10
   - **Order By**: Count (desc)

#### **3.3 Configure Options**

1. **General**:
   - **Title**: "OWASP Top 10 Distribution"
   - **Description**: "Distribution of security events by OWASP category"

2. **Panel Settings**:
   - **Show Legend**: Yes
   - **Legend Position**: Right
   - **Show Values**: Yes

#### **3.4 Save Visualization**

1. **Click**: "Save" button
2. **Name**: "OWASP Top 10 Distribution"
3. **Description**: "OWASP security event categorization"

### **Step 4: Create IP Threat Analysis**

#### **4.1 Create Visualization**

1. **Create New Visualization**: Choose "Heatmap" chart
2. **Select Index Pattern**: Choose `dice-security`

#### **4.2 Configure Metrics**

1. **Value**:
   - **Aggregation**: Count
   - **Custom Label**: "Threat Count"

2. **X-axis**:
   - **Aggregation**: Date Histogram
   - **Field**: `timestamp`
   - **Interval**: 30 minutes
   - **Custom Label**: "Time"

3. **Y-axis**:
   - **Aggregation**: Terms
   - **Field**: `metadata.ip`
   - **Size**: 10
   - **Order By**: Count (desc)

#### **4.3 Configure Options**

1. **General**:
   - **Title**: "IP Threat Analysis"
   - **Description**: "Suspicious IP activity heatmap"

2. **Panel Settings**:
   - **Show Legend**: Yes
   - **Legend Position**: Right

#### **4.4 Save Visualization**

1. **Click**: "Save" button
2. **Name**: "IP Threat Analysis"
3. **Description**: "IP-based threat detection heatmap"

### **Step 5: Create Security Events by Level**

#### **5.1 Create Visualization**

1. **Create New Visualization**: Choose "Bar" chart
2. **Select Index Pattern**: Choose `dice-security`

#### **5.2 Configure Metrics**

1. **Y-axis**:
   - **Aggregation**: Count
   - **Custom Label**: "Security Events"

2. **X-axis**:
   - **Aggregation**: Terms
   - **Field**: `level`
   - **Size**: 5
   - **Order By**: Count (desc)

3. **Split Series**:
   - **Sub Aggregation**: Date Histogram
   - **Field**: `timestamp`
   - **Interval**: 2 hours

#### **5.3 Configure Options**

1. **General**:
   - **Title**: "Security Events by Level"
   - **Description**: "Security events categorized by severity level"

2. **Panel Settings**:
   - **Show Legend**: Yes
   - **Legend Position**: Right

#### **5.4 Save Visualization**

1. **Click**: "Save" button
2. **Name**: "Security Events by Level"
3. **Description**: "Security events by severity level over time"

### **Step 6: Create Security Monitoring Dashboard**

#### **6.1 Create Dashboard**

1. **Navigate**: Go to Dashboard
2. **Create Dashboard**: Click "Create dashboard"

#### **6.2 Add Visualizations**

1. **Add Panel**: Click "Add" button
2. **Select Visualizations**:
   - "Security Auth Events Timeline"
   - "OWASP Top 10 Distribution"
   - "IP Threat Analysis"
   - "Security Events by Level"

#### **6.3 Arrange Layout**

Position visualizations as follows:

```
┌─────────────────────────────────────────────────────────┐
│ Authentication Events Timeline │ OWASP Distribution    │
├─────────────────────────────────────────────────────────┤
│ IP Threat Analysis            │ Security Events Level │
└─────────────────────────────────────────────────────────┘
```

#### **6.4 Configure Dashboard Settings**

1. **General**:
   - **Title**: "DICE Security Monitoring Dashboard"
   - **Description**: "Real-time security threat detection and OWASP compliance tracking"

2. **Time Range**:
   - **Default**: Last 24 hours
   - **Auto Refresh**: 30 seconds

3. **Filters**:
   - Add filter: `level:error OR level:warn`
   - Add filter: `exists:owaspCategory`

#### **6.5 Save Dashboard**

1. **Click**: "Save" button
2. **Name**: "DICE Security Monitoring Dashboard"
3. **Description**: "Comprehensive security monitoring dashboard"

---

## 🚨 **SECURITY ALERTS CONFIGURATION**

### **Alert 1: High Authentication Failure Rate**

#### **Create Alert**

1. **Navigate**: Stack Management → Alerting
2. **Create Alert**: Click "Create alert"
3. **Select Rule Type**: "SIEM Signals"

#### **Configure Alert**

1. **General**:
   - **Name**: "High Authentication Failure Rate"
   - **Description**: "Alert when authentication failures exceed threshold"

2. **Query**:

   ```kuery
   level:error AND action:authentication.failure
   ```

3. **Schedule**:
   - **Interval**: 1 minute

4. **Actions**:
   - **Email**: Send to security team
   - **Log**: Record in security audit log

### **Alert 2: OWASP Security Event Detected**

#### **Create Alert**

1. **Create New Alert**: "OWASP Security Event Detected"

#### **Configure Alert**

1. **Query**:

   ```kuery
   exists:owaspCategory
   ```

2. **Actions**:
   - **Email**: Send to security team
   - **Log**: Record OWASP event

### **Alert 3: Suspicious IP Activity**

#### **Create Alert**

1. **Create New Alert**: "Suspicious IP Activity"

#### **Configure Alert**

1. **Query**:

   ```kuery
   metadata.ip:* AND level:error
   ```

2. **Threshold**: More than 5 events per IP per hour

---

## 📊 **DASHBOARD VALIDATION**

### **Test Data Verification**

Verify that security data is visible:

```bash
# Check security data count
curl -s "localhost:9200/dice-security-*/_count" | jq '.count'

# Check recent security events
curl -s "localhost:9200/dice-security-*/_search?q=level:error&size=5" | jq '.hits.hits'
```

### **Dashboard Functionality Tests**

1. **Time Range**: Verify time range picker works (Last 24h)
2. **Filters**: Test security filters
3. **Drill-down**: Test visualization interactions
4. **Refresh**: Verify auto-refresh (30s)
5. **Export**: Test dashboard export features

### **Visualization Tests**

1. **Authentication Timeline**: Should show events over time
2. **OWASP Distribution**: Should show pie chart of categories
3. **IP Threat Analysis**: Should show heatmap of IP activity
4. **Events by Level**: Should show bar chart of severity levels

---

## 🎯 **SUCCESS CRITERIA**

### **Implementation Checklist**

- [ ] **Authentication Timeline**: Shows events over time with action breakdown
- [ ] **OWASP Distribution**: Displays security events by OWASP category
- [ ] **IP Threat Analysis**: Shows suspicious IP activity heatmap
- [ ] **Events by Level**: Shows security events by severity level
- [ ] **Dashboard Layout**: All visualizations properly arranged
- [ ] **Time Range**: Configured for last 24 hours
- [ ] **Filters**: Security-specific filters applied
- [ ] **Auto Refresh**: Set to 30 seconds

### **Operational Checklist**

- [ ] **Real-time Data**: Dashboard shows current security events
- [ ] **Alert Functionality**: Security alerts configured and tested
- [ ] **Performance**: Dashboard loads within 5 seconds
- [ ] **Accessibility**: Dashboard accessible to security team

### **Security Value Checklist**

- [ ] **Threat Detection**: Real-time authentication failure monitoring
- [ ] **OWASP Compliance**: Security event categorization working
- [ ] **IP Analysis**: Suspicious IP activity visible
- [ ] **Alert Response**: Security team notified of threats

---

## 📝 **NEXT STEPS**

### **Immediate Actions**

1. **Create Dashboard**: Follow the step-by-step guide above
2. **Configure Alerts**: Set up the 3 security alerts
3. **Test Functionality**: Verify all visualizations work correctly
4. **Share Access**: Provide dashboard access to security team

### **Future Enhancements**

1. **Advanced Filters**: Add more sophisticated security filters
2. **Custom Visualizations**: Create more detailed security charts
3. **Integration**: Connect with external security tools
4. **Automation**: Implement automated threat response

---

## 🔧 **TROUBLESHOOTING**

### **Common Issues**

1. **No Data Visible**:
   - Check index pattern: `dice-security`
   - Verify time range: Last 24 hours
   - Check filters: Remove restrictive filters

2. **Visualization Errors**:
   - Verify field names: `timestamp`, `action`, `owaspCategory`, `level`
   - Check data format: Ensure JSON structure is correct

3. **Performance Issues**:
   - Reduce time range: Try last 1 hour
   - Limit data size: Reduce aggregation size
   - Optimize queries: Use specific field filters

### **Data Verification**

```bash
# Check if security data exists
curl -s "localhost:9200/dice-security-*/_search?size=1" | jq '.hits.hits[0]._source'

# Check field mapping
curl -s "localhost:9200/dice-security-*/_mapping" | jq '.dice-security-*.mappings.properties'
```

---

**Document Status**: ✅ **READY FOR IMPLEMENTATION**  
**Last Updated**: 2025-08-06 18:15 BST  
**Owner**: Security Team  
**Access**: <http://localhost:5601>  
**Dashboard URL**: <http://localhost:5601/app/dashboards#/view/dice-security-monitoring-dashboard>
