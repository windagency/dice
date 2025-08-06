# Operational Overview Dashboard Manual Setup Guide

**Version**: 1.0 - System-Wide Operational Intelligence  
**Created**: 2025-08-06 18:25 BST  
**Status**: 🚧 **READY FOR MANUAL IMPLEMENTATION**  
**Priority**: LOW - Cross-service correlation and system-wide trends

---

## 🎯 **DASHBOARD OVERVIEW**

The Operational Overview Dashboard provides comprehensive system-wide monitoring with cross-service correlation, log volume analysis, performance trends, and capacity planning indicators. This dashboard is essential for understanding the overall system health, identifying operational patterns, and making data-driven decisions about infrastructure and development.

### **Key Metrics Monitored**

- **Cross-Service Correlation**: Request tracing across all services
- **Log Volume Analysis**: Log volume by service and level
- **System Performance Trends**: Overall system performance metrics
- **Development Workflow Metrics**: Deployment and development tracking
- **Capacity Planning Indicators**: Resource usage trends and forecasting

---

## 📊 **DASHBOARD COMPONENTS**

### **1. Cross-Service Correlation Visualization**

**Type**: Line Chart  
**Purpose**: Track request flow and correlation across all services

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Line** chart
   - Choose **dice-logs-*** index pattern

2. **Configure Y-axis**:
   - **Aggregation**: Count
   - **Custom Label**: "Request Count"

3. **Configure X-axis**:
   - **Aggregation**: Date Histogram
   - **Field**: `@timestamp`
   - **Interval**: 1 hour
   - **Custom Label**: "Time"

4. **Add Split Series**:
   - **Sub Aggregation**: Terms
   - **Field**: `service`
   - **Size**: 10
   - **Custom Label**: "Services"

5. **Add Filter**:
   - **Field**: `correlationId`
   - **Operator**: exists
   - **Label**: "Correlated Requests Only"

6. **Save Visualization**:
   - **Title**: "Cross-Service Correlation"
   - **Description**: "Request flow and correlation across all services over time"

### **2. Log Volume Analysis Visualization**

**Type**: Area Chart  
**Purpose**: Monitor log volume by service and level

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Area** chart
   - Choose **dice-logs-*** index pattern

2. **Configure Y-axis**:
   - **Aggregation**: Count
   - **Custom Label**: "Log Volume"

3. **Configure X-axis**:
   - **Aggregation**: Date Histogram
   - **Field**: `@timestamp`
   - **Interval**: 1 hour
   - **Custom Label**: "Time"

4. **Add Split Series**:
   - **Sub Aggregation**: Terms
   - **Field**: `service`
   - **Size**: 10
   - **Custom Label**: "Services"

5. **Add Sub Aggregation**:
   - **Sub Aggregation**: Terms
   - **Field**: `level`
   - **Size**: 5
   - **Custom Label**: "Log Levels"

6. **Save Visualization**:
   - **Title**: "Log Volume Analysis"
   - **Description**: "Log volume trends by service and level"

### **3. System Performance Trends Visualization**

**Type**: Line Chart  
**Purpose**: Monitor overall system performance metrics

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Line** chart
   - Choose **dice-logs-*** index pattern

2. **Configure Y-axis (Multiple Metrics)**:
   - **Metric 1**: Count
     - **Aggregation**: Count
     - **Custom Label**: "Total Requests"
   
   - **Metric 2**: Count
     - **Aggregation**: Count
     - **Filter**: `level:error`
     - **Custom Label**: "Error Count"

3. **Configure X-axis**:
   - **Aggregation**: Date Histogram
   - **Field**: `@timestamp`
   - **Interval**: 1 hour
   - **Custom Label**: "Time"

4. **Add Filter**:
   - **Field**: `service`
   - **Operator**: exists
   - **Label**: "All Services"

5. **Save Visualization**:
   - **Title**: "System Performance Trends"
   - **Description**: "Overall system performance and error trends"

### **4. Development Workflow Metrics Visualization**

**Type**: Data Table  
**Purpose**: Track deployment and development activities

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Data Table**
   - Choose **dice-logs-*** index pattern

2. **Configure Metrics**:
   - **Metric 1**: Count
     - **Aggregation**: Count
     - **Custom Label**: "Activity Count"
   
   - **Metric 2**: Average
     - **Aggregation**: Average
     - **Field**: `metadata.duration` (if available)
     - **Custom Label**: "Avg Duration"

3. **Configure Buckets**:
   - **Split Rows**:
     - **Aggregation**: Terms
     - **Field**: `service`
     - **Size**: 10
     - **Custom Label**: "Service"

4. **Add Sub Aggregation**:
   - **Sub Aggregation**: Terms
   - **Field**: `action`
   - **Size**: 10
   - **Custom Label**: "Action"

5. **Add Filter**:
   - **Field**: `tags`
   - **Operator**: is one of
   - **Values**: `deployment`, `development`, `workflow`
   - **Label**: "Workflow Activities Only"

6. **Save Visualization**:
   - **Title**: "Development Workflow Metrics"
   - **Description**: "Deployment and development activity tracking"

### **5. Capacity Planning Indicators Visualization**

**Type**: Scatter Plot  
**Purpose**: Monitor resource usage trends and forecasting

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Scatter Plot**
   - Choose **dice-logs-*** index pattern

2. **Configure X-axis**:
   - **Aggregation**: Date Histogram
   - **Field**: `@timestamp`
   - **Interval**: 1 hour
   - **Custom Label**: "Time"

3. **Configure Y-axis**:
   - **Aggregation**: Average
   - **Field**: `metadata.cpu` (if available)
   - **Custom Label**: "CPU Usage"

4. **Configure Buckets**:
   - **Split Series**:
     - **Aggregation**: Terms
     - **Field**: `service`
     - **Size**: 10
     - **Custom Label**: "Service"

5. **Add Filter**:
   - **Field**: `metadata.cpu`
   - **Operator**: exists
   - **Label**: "Resource Data Only"

6. **Save Visualization**:
   - **Title**: "Capacity Planning Indicators"
   - **Description**: "Resource usage trends and capacity forecasting"

### **6. Operational Intelligence Summary Visualization**

**Type**: Metric Visualization  
**Purpose**: Provide key operational metrics at a glance

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Metric**
   - Choose **dice-logs-*** index pattern

2. **Configure Metrics**:
   - **Metric 1**: Count
     - **Aggregation**: Count
     - **Custom Label**: "Total Operations"
   
   - **Metric 2**: Count
     - **Aggregation**: Count
     - **Filter**: `level:error`
     - **Custom Label**: "Errors"
   
   - **Metric 3**: Cardinality
     - **Aggregation**: Cardinality
     - **Field**: `correlationId`
     - **Custom Label**: "Unique Requests"

3. **Add Filter**:
   - **Field**: `service`
   - **Operator**: exists
   - **Label**: "All Services"

4. **Save Visualization**:
   - **Title**: "Operational Intelligence Summary"
   - **Description**: "Key operational metrics and system health indicators"

---

## 🏗️ **DASHBOARD ASSEMBLY**

### **Step 1: Create Dashboard**

1. **Navigate to Dashboards**:
   - Go to **Analytics** → **Dashboards**
   - Click **Create dashboard**

2. **Add Visualizations**:
   - Click **Add** → **Add panels**
   - Add all 6 visualizations:
     - Cross-Service Correlation
     - Log Volume Analysis
     - System Performance Trends
     - Development Workflow Metrics
     - Capacity Planning Indicators
     - Operational Intelligence Summary

### **Step 2: Configure Layout**

**Recommended Layout**:
- **Row 1**: Operational Intelligence Summary (full width)
- **Row 2**: Cross-Service Correlation (left) + System Performance Trends (right)
- **Row 3**: Log Volume Analysis (full width)
- **Row 4**: Development Workflow Metrics (left) + Capacity Planning Indicators (right)

### **Step 3: Dashboard Settings**

1. **Time Range**: Last 24 hours
2. **Auto-refresh**: Every 30 seconds
3. **Global Filters**:
   - **All Services**: `service:*`
   - **Correlated Data**: `correlationId:*`

### **Step 4: Save Dashboard**

- **Title**: "Operational Overview Dashboard"
- **Description**: "System-wide operational intelligence with cross-service correlation and capacity planning"

---

## 🚨 **OPERATIONAL ALERTS**

### **Alert 1: Cross-Service Correlation Failure**

**Configuration**:
- **Name**: "Cross-Service Correlation Failure"
- **Rule Type**: Elasticsearch query
- **Query**: `NOT correlationId:*`
- **Condition**: `count > 0`
- **Severity**: Medium
- **Action**: Notify DevOps team

### **Alert 2: Log Volume Anomaly**

**Configuration**:
- **Name**: "Log Volume Anomaly"
- **Rule Type**: Elasticsearch query
- **Query**: `service:*`
- **Condition**: `volume spike > 300% baseline`
- **Severity**: High
- **Action**: Notify infrastructure team

### **Alert 3: System Performance Degradation**

**Configuration**:
- **Name**: "System Performance Degradation"
- **Rule Type**: Elasticsearch query
- **Query**: `level:error`
- **Condition**: `count > 10 per minute`
- **Severity**: Critical
- **Action**: Emergency notification

---

## 📊 **OPERATIONAL METRICS**

### **Key Operational Indicators (KOIs)**

| **Metric**                    | **Target** | **Alert Threshold** | **Measurement**              |
| ----------------------------- | ---------- | ------------------- | ---------------------------- |
| **Cross-Service Correlation** | 100%       | < 95%               | Request tracing coverage     |
| **Log Volume Stability**      | Stable     | > 300% baseline     | Log ingestion rate           |
| **System Performance**        | > 99%      | < 95%               | Overall system health        |
| **Error Rate**                | < 1%       | > 5%                | System-wide error percentage |
| **Capacity Utilization**      | < 80%      | > 90%               | Resource usage percentage    |
| **Development Velocity**      | Stable     | Drop > 50%          | Deployment frequency         |

### **Operational Targets**

- **System Reliability**: 99.9% uptime across all services
- **Request Tracing**: 100% correlation ID coverage
- **Log Pipeline**: Stable ingestion rates with <5% variance
- **Performance**: <1 second average response time
- **Error Tolerance**: <1% error rate across all services
- **Capacity Planning**: Proactive scaling at 80% utilization

---

## 🔧 **TESTING & VALIDATION**

### **Test Script Usage**

```bash
# Test Operational Overview Dashboard
./infrastructure/scripts/test-operational-overview-dashboard.sh

# Check operational data
curl -s "http://localhost:9200/dice-logs-*/_search?size=5" | jq '.hits.hits[] | {service: ._source.service, correlationId: ._source.correlationId, level: ._source.level}'

# Monitor real-time operations
./infrastructure/scripts/logging-monitor.sh --operational --follow
```

### **Validation Checklist**

- [ ] **Cross-Service Correlation**: Request flow visible across services
- [ ] **Log Volume Analysis**: Volume trends by service and level accurate
- [ ] **System Performance**: Overall performance metrics displaying correctly
- [ ] **Development Workflow**: Deployment and development tracking visible
- [ ] **Capacity Planning**: Resource usage trends and forecasting accurate
- [ ] **Operational Intelligence**: Key metrics summary displaying correctly
- [ ] **Operational Alerts**: All 3 alerts properly configured
- [ ] **Dashboard Performance**: Queries complete within 5 seconds
- [ ] **Real-time Updates**: Auto-refresh working correctly

---

## 📈 **OPTIMIZATION TIPS**

### **Dashboard Performance**

1. **Query Optimization**:
   - Use appropriate time ranges (24h for real-time, 7d for trends)
   - Limit aggregation buckets to prevent memory issues
   - Use filters to reduce data volume

2. **Visualization Best Practices**:
   - Keep visualizations focused on specific operational metrics
   - Use appropriate chart types for data representation
   - Ensure proper color coding for performance levels

3. **Alert Tuning**:
   - Start with conservative thresholds
   - Monitor alert frequency and adjust as needed
   - Use different severity levels for different operational issues

### **Data Quality**

1. **Ensure Consistent Logging**:
   - All services include correlation IDs
   - Service names and levels are consistent
   - Timestamps are accurate and synchronized

2. **Monitor Data Volume**:
   - Check log ingestion rates
   - Monitor storage usage
   - Implement data retention policies

---

## 🎯 **SUCCESS CRITERIA**

### **Implementation Success**

- [ ] **All 6 Visualizations**: Created and displaying data correctly
- [ ] **Dashboard Assembly**: Proper layout and configuration
- [ ] **Alert Configuration**: 3 operational alerts active
- [ ] **Data Accuracy**: Operational metrics match actual system behavior
- [ ] **Query Performance**: Dashboard loads within 5 seconds

### **Operational Success**

- [ ] **Real-time Monitoring**: Operational issues detected within 5 minutes
- [ ] **Alert Response**: DevOps team notified of operational degradation
- [ ] **Trend Analysis**: System-wide patterns visible
- [ ] **Capacity Planning**: Resource usage trends identified
- [ ] **Cross-Service Visibility**: Request flow across services tracked

### **Business Value**

- [ ] **Improved System Reliability**: Operational issues identified and resolved quickly
- [ ] **Better Capacity Planning**: Resource usage optimized based on trends
- [ ] **Enhanced Visibility**: Cross-service correlation provides complete system view
- [ ] **Proactive Operations**: Issues detected before user impact
- [ ] **Data-Driven Decisions**: Operational intelligence guides infrastructure decisions

---

## 📝 **NEXT STEPS**

### **Immediate Actions**

1. **Create Visualizations**: Follow the step-by-step guide above
2. **Assemble Dashboard**: Combine all visualizations with proper layout
3. **Configure Alerts**: Set up the 3 operational alerts
4. **Test Functionality**: Validate all components work correctly
5. **Monitor Performance**: Ensure dashboard queries are fast

### **Ongoing Maintenance**

1. **Regular Review**: Check dashboard performance weekly
2. **Alert Tuning**: Adjust thresholds based on actual operational patterns
3. **Data Quality**: Monitor log consistency and completeness
4. **Performance Optimization**: Optimize queries and visualizations as needed

---

**Document Status**: ✅ **READY FOR IMPLEMENTATION**  
**Next Review**: 2025-08-13  
**Owner**: DevOps/Infrastructure Team  
**Stakeholders**: Development, Operations, Management Teams
