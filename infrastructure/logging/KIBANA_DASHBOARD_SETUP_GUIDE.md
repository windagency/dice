# DICE Kibana Dashboard Setup Guide

**Version**: 1.0 - Manual Setup Guide  
**Created**: 2025-08-06 18:00 BST  
**Status**: ✅ **READY FOR IMPLEMENTATION**  
**Prerequisites**: ELK stack running, index patterns created

---

## 🎯 **OVERVIEW**

This guide provides step-by-step instructions for creating the DICE Kibana dashboards manually through the Kibana UI. The foundation (index templates, patterns, test data) has been automated and is ready for dashboard creation.

### **✅ Completed Foundation**

- [x] **Elasticsearch Index Templates**: All templates created successfully
- [x] **Kibana Index Patterns**: 4 patterns configured and ready
- [x] **Test Data**: Sample data generated for all indices
- [x] **ELK Stack Health**: All services operational

### **📊 Available Index Patterns**

| **Pattern Name**   | **Index Pattern**    | **Description**                    | **Data Available** |
| ------------------ | -------------------- | ---------------------------------- | ------------------ |
| `dice-security`    | `dice-security-*`    | Security events and OWASP tracking | ✅ 10 test records  |
| `dice-performance` | `dice-performance-*` | API performance metrics            | ✅ 20 test records  |
| `dice-logs`        | `dice-logs-*`        | General application logs           | ✅ 15 test records  |
| `dice-health`      | `dice-health-*`      | Health monitoring data             | ✅ Ready for data   |

---

## 🚀 **DASHBOARD CREATION STEPS**

### **Step 1: Access Kibana**

1. **Open Kibana**: Navigate to http://localhost:5601
2. **Verify Access**: You should see the Kibana welcome page
3. **Check Index Patterns**: Go to Stack Management → Index Patterns to verify the 4 patterns are available

### **Step 2: Create Security Monitoring Dashboard**

#### **2.1 Authentication Events Timeline**

1. **Navigate**: Go to Visualize Library
2. **Create Visualization**: Click "Create visualization"
3. **Select Type**: Choose "Line" chart
4. **Select Index Pattern**: Choose `dice-security`
5. **Configure Metrics**:
   - **Y-axis**: Count
   - **X-axis**: Date Histogram (timestamp)
   - **Split Series**: Terms (action field)
6. **Save**: Name it "Security Auth Events Timeline"

#### **2.2 OWASP Top 10 Distribution**

1. **Create New Visualization**: Choose "Pie" chart
2. **Select Index Pattern**: Choose `dice-security`
3. **Configure Metrics**:
   - **Slice Size**: Count
   - **Split Slices**: Terms (owaspCategory field)
4. **Save**: Name it "OWASP Top 10 Distribution"

#### **2.3 IP Threat Analysis**

1. **Create New Visualization**: Choose "Heatmap" chart
2. **Select Index Pattern**: Choose `dice-security`
3. **Configure Metrics**:
   - **Value**: Count
   - **X-axis**: Date Histogram (timestamp, 30m intervals)
   - **Y-axis**: Terms (ip field)
4. **Save**: Name it "IP Threat Analysis"

#### **2.4 Create Security Dashboard**

1. **Navigate**: Go to Dashboard
2. **Create Dashboard**: Click "Create dashboard"
3. **Add Visualizations**: Add all 3 security visualizations
4. **Arrange Layout**: Position visualizations as needed
5. **Save**: Name it "DICE Security Monitoring Dashboard"

### **Step 3: Create API Performance Dashboard**

#### **3.1 Response Time Percentiles**

1. **Create Visualization**: Choose "Line" chart
2. **Select Index Pattern**: Choose `dice-performance`
3. **Configure Metrics**:
   - **Y-axis**: Percentiles (metadata.duration field)
   - **X-axis**: Date Histogram (timestamp, 5m intervals)
   - **Split Series**: Multiple percentiles (50, 95, 99)
4. **Save**: Name it "Response Time Percentiles"

#### **3.2 Error Rate by Endpoint**

1. **Create Visualization**: Choose "Bar" chart
2. **Select Index Pattern**: Choose `dice-performance`
3. **Configure Metrics**:
   - **Y-axis**: Count
   - **X-axis**: Terms (metadata.endpoint field)
   - **Split Series**: Filters (metadata.statusCode:>=400)
4. **Save**: Name it "Error Rate by Endpoint"

#### **3.3 Request Volume Trends**

1. **Create Visualization**: Choose "Area" chart
2. **Select Index Pattern**: Choose `dice-performance`
3. **Configure Metrics**:
   - **Y-axis**: Count
   - **X-axis**: Date Histogram (timestamp, 5m intervals)
4. **Save**: Name it "Request Volume Trends"

#### **3.4 Create Performance Dashboard**

1. **Create Dashboard**: Add all 3 performance visualizations
2. **Save**: Name it "DICE API Performance Dashboard"

### **Step 4: Create Service Health Dashboard**

#### **4.1 Container Status Overview**

1. **Create Visualization**: Choose "Table" chart
2. **Select Index Pattern**: Choose `dice-logs`
3. **Configure Metrics**:
   - **Metrics**: Count
   - **Buckets**: Split Rows (service field)
   - **Sub-buckets**: Split Rows (level field)
4. **Save**: Name it "Container Status Overview"

#### **4.2 Log Volume by Service**

1. **Create Visualization**: Choose "Bar" chart
2. **Select Index Pattern**: Choose `dice-logs`
3. **Configure Metrics**:
   - **Y-axis**: Count
   - **X-axis**: Terms (service field)
   - **Split Series**: Date Histogram (timestamp, 10m intervals)
4. **Save**: Name it "Log Volume by Service"

#### **4.3 Create Health Dashboard**

1. **Create Dashboard**: Add both health visualizations
2. **Save**: Name it "DICE Service Health Dashboard"

### **Step 5: Create User Activity Dashboard**

#### **5.1 User Interaction Heatmap**

1. **Create Visualization**: Choose "Heatmap" chart
2. **Select Index Pattern**: Choose `dice-logs`
3. **Configure Metrics**:
   - **Value**: Count
   - **X-axis**: Date Histogram (timestamp, 1h intervals)
   - **Y-axis**: Terms (component field)
4. **Add Filter**: `service:pwa-frontend`
5. **Save**: Name it "User Interaction Heatmap"

#### **5.2 Error Tracking by Browser**

1. **Create Visualization**: Choose "Pie" chart
2. **Select Index Pattern**: Choose `dice-logs`
3. **Configure Metrics**:
   - **Slice Size**: Count
   - **Split Slices**: Terms (level field)
4. **Add Filter**: `service:pwa-frontend`
5. **Save**: Name it "Error Tracking by Browser"

#### **5.3 Create User Activity Dashboard**

1. **Create Dashboard**: Add both user activity visualizations
2. **Save**: Name it "DICE User Activity Dashboard"

### **Step 6: Create Operational Overview Dashboard**

#### **6.1 Cross-Service Correlation**

1. **Create Visualization**: Choose "Line" chart
2. **Select Index Pattern**: Choose `dice-logs`
3. **Configure Metrics**:
   - **Y-axis**: Count
   - **X-axis**: Date Histogram (timestamp, 5m intervals)
   - **Split Series**: Terms (service field)
4. **Save**: Name it "Cross-Service Correlation"

#### **6.2 Log Volume Analysis**

1. **Create Visualization**: Choose "Area" chart
2. **Select Index Pattern**: Choose `dice-logs`
3. **Configure Metrics**:
   - **Y-axis**: Count
   - **X-axis**: Date Histogram (timestamp, 5m intervals)
4. **Save**: Name it "Log Volume Analysis"

#### **6.3 Create Operational Dashboard**

1. **Create Dashboard**: Add both operational visualizations
2. **Save**: Name it "DICE Operational Overview Dashboard"

---

## 🔧 **DASHBOARD CONFIGURATION**

### **Time Range Settings**

Configure each dashboard with appropriate time ranges:

| **Dashboard**        | **Default Time Range** | **Auto Refresh** |
| -------------------- | ---------------------- | ---------------- |
| Security Monitoring  | Last 24 hours          | 30 seconds       |
| API Performance      | Last 1 hour            | 10 seconds       |
| Service Health       | Last 1 hour            | 30 seconds       |
| User Activity        | Last 24 hours          | 60 seconds       |
| Operational Overview | Last 1 hour            | 30 seconds       |

### **Filter Configuration**

Add useful filters to each dashboard:

#### **Security Dashboard Filters**
- `level:error OR level:warn`
- `exists:owaspCategory`

#### **Performance Dashboard Filters**
- `exists:metadata.duration`
- `metadata.statusCode:*`

#### **Health Dashboard Filters**
- `service:*` (exclude system logs)

#### **User Activity Dashboard Filters**
- `service:pwa-frontend`
- `level:error OR level:info`

#### **Operational Dashboard Filters**
- No specific filters (show all data)

---

## 🚨 **ALERT CONFIGURATION**

### **Security Alerts**

1. **Navigate**: Stack Management → Alerting
2. **Create Alert**: "High Authentication Failure Rate"
   - **Condition**: Count of `level:error AND action:authentication.failure` > 5 per minute
   - **Action**: Email notification to security team

3. **Create Alert**: "OWASP Security Event Detected"
   - **Condition**: Exists `owaspCategory`
   - **Action**: Log security event

### **Performance Alerts**

1. **Create Alert**: "High API Response Time"
   - **Condition**: Percentile(metadata.duration, 95) > 2000ms
   - **Action**: Email notification to DevOps team

2. **Create Alert**: "High Error Rate"
   - **Condition**: Rate of `level:error` > 5% for 5 minutes
   - **Action**: Email notification to DevOps team

### **Health Alerts**

1. **Create Alert**: "Service Health Degradation"
   - **Condition**: Count of `level:error` by service > threshold
   - **Action**: Email notification to operations team

---

## 📊 **DASHBOARD VALIDATION**

### **Test Data Verification**

Verify that test data is visible in each dashboard:

```bash
# Check security data
curl -s "localhost:9200/dice-security-*/_search?size=5" | jq '.hits.hits'

# Check performance data  
curl -s "localhost:9200/dice-performance-*/_search?size=5" | jq '.hits.hits'

# Check PWA data
curl -s "localhost:9200/dice-logs-*/_search?q=service:pwa-frontend&size=5" | jq '.hits.hits'
```

### **Dashboard Functionality Tests**

1. **Time Range**: Verify time range picker works
2. **Filters**: Test dashboard filters
3. **Drill-down**: Test visualization interactions
4. **Refresh**: Verify auto-refresh functionality
5. **Export**: Test dashboard export features

---

## 🎯 **SUCCESS CRITERIA**

### **Implementation Checklist**

- [ ] **Security Dashboard**: Authentication timeline, OWASP distribution, IP analysis
- [ ] **Performance Dashboard**: Response time percentiles, error rates, volume trends
- [ ] **Health Dashboard**: Container status, log volume by service
- [ ] **User Activity Dashboard**: Interaction heatmap, error tracking
- [ ] **Operational Dashboard**: Cross-service correlation, log volume analysis

### **Operational Checklist**

- [ ] **Time Ranges**: All dashboards configured with appropriate time ranges
- [ ] **Filters**: Useful filters applied to each dashboard
- [ ] **Alerts**: Critical alerts configured and tested
- [ ] **Performance**: Dashboard queries complete within 5 seconds
- [ ] **Accessibility**: Dashboards accessible to all team members

### **Business Value Checklist**

- [ ] **Security Monitoring**: Real-time threat detection operational
- [ ] **Performance Tracking**: API performance issues visible
- [ ] **User Experience**: Frontend issues trackable
- [ ] **System Health**: Infrastructure status monitorable
- [ ] **Operational Intelligence**: Cross-service correlation working

---

## 📝 **NEXT STEPS**

### **Immediate Actions**

1. **Create Dashboards**: Follow the step-by-step guide above
2. **Configure Alerts**: Set up critical monitoring alerts
3. **Test Functionality**: Verify all dashboards work correctly
4. **Document Access**: Share dashboard URLs with team

### **Future Enhancements**

1. **Custom Visualizations**: Create more sophisticated charts
2. **Advanced Alerts**: Implement complex alerting rules
3. **Dashboard Sharing**: Set up team access and permissions
4. **Performance Optimization**: Optimize queries for large datasets

---

**Document Status**: ✅ **READY FOR IMPLEMENTATION**  
**Last Updated**: 2025-08-06 18:00 BST  
**Owner**: Infrastructure Team  
**Access**: http://localhost:5601
