# Service Health Dashboard Manual Setup Guide

**Version**: 1.0 - Infrastructure Health Monitoring  
**Created**: 2025-08-06 18:15 BST  
**Status**: 🚧 **READY FOR MANUAL IMPLEMENTATION**  
**Priority**: MEDIUM - Infrastructure health and resource monitoring

---

## 🎯 **DASHBOARD OVERVIEW**

The Service Health Dashboard provides comprehensive monitoring of infrastructure health, container status, resource utilization, and service availability. This dashboard is essential for maintaining system reliability and identifying infrastructure issues before they impact users.

### **Key Metrics Monitored**

- **Container Status Overview**: Docker container health and status
- **ELK Stack Health**: Elasticsearch, Kibana, Fluent Bit operational status
- **Resource Usage Trends**: CPU, memory, disk utilization patterns
- **Log Ingestion Rates**: Log pipeline performance and throughput
- **Infrastructure Service Status**: PostgreSQL, Redis, Temporal health

---

## 📊 **DASHBOARD COMPONENTS**

### **1. Container Status Overview Visualization**

**Type**: Data Table  
**Purpose**: Monitor Docker container health and status across all services

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Data Table**
   - Choose **dice-logs-*** index pattern

2. **Configure Metrics**:
   - **Metric 1**: Count
     - **Aggregation**: Count
     - **Custom Label**: "Container Count"
   
   - **Metric 2**: Average
     - **Aggregation**: Average
     - **Field**: `metadata.uptime` (if available)
     - **Custom Label**: "Avg Uptime"

3. **Configure Buckets**:
   - **Split Rows**:
     - **Aggregation**: Terms
     - **Field**: `service`
     - **Size**: 10
     - **Custom Label**: "Service"

4. **Add Sub Aggregation**:
   - **Sub Aggregation**: Terms
   - **Field**: `level`
   - **Size**: 5
   - **Custom Label**: "Status"

5. **Add Filter**:
   - **Field**: `service`
   - **Operator**: exists
   - **Label**: "Service Logs Only"

6. **Save Visualization**:
   - **Title**: "Container Status Overview"
   - **Description**: "Docker container health and status by service"

### **2. Log Volume by Service Visualization**

**Type**: Vertical Bar Chart  
**Purpose**: Monitor log volume and activity by service

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Vertical Bar** chart
   - Choose **dice-logs-*** index pattern

2. **Configure Y-axis**:
   - **Aggregation**: Count
   - **Custom Label**: "Log Volume"

3. **Configure X-axis**:
   - **Aggregation**: Terms
   - **Field**: `service`
   - **Size**: 10
   - **Custom Label**: "Services"

4. **Add Split Series**:
   - **Sub Aggregation**: Terms
   - **Field**: `level`
   - **Size**: 5
   - **Custom Label**: "Log Levels"

5. **Add Filter**:
   - **Field**: `service`
   - **Operator**: exists
   - **Label**: "Valid Services Only"

6. **Save Visualization**:
   - **Title**: "Log Volume by Service"
   - **Description**: "Log volume distribution by service and level"

### **3. ELK Stack Health Visualization**

**Type**: Gauge Chart  
**Purpose**: Monitor Elasticsearch, Kibana, and Fluent Bit health

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Gauge**
   - Choose **dice-logs-*** index pattern

2. **Configure Metrics**:
   - **Aggregation**: Count
   - **Custom Label**: "ELK Health Score"

3. **Configure Gauge Settings**:
   - **Min**: 0
   - **Max**: 100
   - **Thresholds**:
     - **Green**: 80-100 (Healthy)
     - **Yellow**: 60-79 (Warning)
     - **Red**: 0-59 (Critical)

4. **Add Filter**:
   - **Field**: `service`
   - **Operator**: is one of
   - **Values**: `elasticsearch`, `kibana`, `fluent-bit`
   - **Label**: "ELK Services Only"

5. **Save Visualization**:
   - **Title**: "ELK Stack Health"
   - **Description**: "Elasticsearch, Kibana, and Fluent Bit health status"

### **4. Infrastructure Service Status Visualization**

**Type**: Horizontal Bar Chart  
**Purpose**: Monitor PostgreSQL, Redis, Temporal, and other infrastructure services

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Horizontal Bar** chart
   - Choose **dice-logs-*** index pattern

2. **Configure Y-axis**:
   - **Aggregation**: Count
   - **Custom Label**: "Service Status"

3. **Configure X-axis**:
   - **Aggregation**: Terms
   - **Field**: `service`
   - **Size**: 10
   - **Custom Label**: "Infrastructure Services"

4. **Add Split Series**:
   - **Sub Aggregation**: Terms
   - **Field**: `level`
   - **Size**: 5
   - **Custom Label**: "Health Status"

5. **Add Filter**:
   - **Field**: `service`
   - **Operator**: is one of
   - **Values**: `postgresql`, `redis`, `temporal`, `backend-api`
   - **Label**: "Infrastructure Services Only"

6. **Save Visualization**:
   - **Title**: "Infrastructure Service Status"
   - **Description**: "Health status of infrastructure services"

### **5. Resource Usage Trends Visualization**

**Type**: Line Chart  
**Purpose**: Monitor CPU, memory, and disk usage trends

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Line** chart
   - Choose **dice-logs-*** index pattern

2. **Configure Y-axis (Multiple Metrics)**:
   - **Metric 1**: Average
     - **Aggregation**: Average
     - **Field**: `metadata.cpu` (if available)
     - **Custom Label**: "CPU Usage"
   
   - **Metric 2**: Average
     - **Aggregation**: Average
     - **Field**: `metadata.memory` (if available)
     - **Custom Label**: "Memory Usage"
   
   - **Metric 3**: Average
     - **Aggregation**: Average
     - **Field**: `metadata.disk` (if available)
     - **Custom Label**: "Disk Usage"

3. **Configure X-axis**:
   - **Aggregation**: Date Histogram
   - **Field**: `@timestamp`
   - **Interval**: 1 hour
   - **Custom Label**: "Time"

4. **Add Filter**:
   - **Field**: `metadata.cpu`
   - **Operator**: exists
   - **Label**: "Resource Data Only"

5. **Save Visualization**:
   - **Title**: "Resource Usage Trends"
   - **Description**: "CPU, memory, and disk usage trends over time"

### **6. Health Degradation Alerts Visualization**

**Type**: Metric Visualization  
**Purpose**: Monitor health degradation and alert status

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Metric**
   - Choose **dice-logs-*** index pattern

2. **Configure Metrics**:
   - **Aggregation**: Count
   - **Custom Label**: "Health Alerts"

3. **Add Filter**:
   - **Field**: `level`
   - **Operator**: is one of
   - **Values**: `error`, `warn`
   - **Label**: "Health Issues Only"

4. **Save Visualization**:
   - **Title**: "Health Degradation Alerts"
   - **Description**: "Count of health degradation alerts and warnings"

---

## 🏗️ **DASHBOARD ASSEMBLY**

### **Step 1: Create Dashboard**

1. **Navigate to Dashboards**:
   - Go to **Analytics** → **Dashboards**
   - Click **Create dashboard**

2. **Add Visualizations**:
   - Click **Add** → **Add panels**
   - Add all 6 visualizations:
     - Container Status Overview
     - Log Volume by Service
     - ELK Stack Health
     - Infrastructure Service Status
     - Resource Usage Trends
     - Health Degradation Alerts

### **Step 2: Configure Layout**

**Recommended Layout**:
- **Row 1**: Container Status Overview (full width)
- **Row 2**: ELK Stack Health (left) + Health Degradation Alerts (right)
- **Row 3**: Infrastructure Service Status (full width)
- **Row 4**: Log Volume by Service (left) + Resource Usage Trends (right)

### **Step 3: Dashboard Settings**

1. **Time Range**: Last 24 hours
2. **Auto-refresh**: Every 30 seconds
3. **Global Filters**:
   - **Service Logs**: `service:*`
   - **Health Data**: `level:error OR level:warn OR level:info`

### **Step 4: Save Dashboard**

- **Title**: "Service Health Dashboard"
- **Description**: "Infrastructure health monitoring with container status, resource usage, and service availability"

---

## 🚨 **HEALTH ALERTS**

### **Alert 1: Container Health Degradation**

**Configuration**:
- **Name**: "Container Health Degradation"
- **Rule Type**: Elasticsearch query
- **Query**: `level:error AND service:*`
- **Condition**: `count > 0`
- **Severity**: High
- **Action**: Notify DevOps team

### **Alert 2: Resource Usage Threshold**

**Configuration**:
- **Name**: "High Resource Usage"
- **Rule Type**: Elasticsearch query
- **Query**: `metadata.cpu:>80 OR metadata.memory:>80`
- **Condition**: `count > 0`
- **Severity**: Medium
- **Action**: Notify infrastructure team

### **Alert 3: Service Unavailability**

**Configuration**:
- **Name**: "Service Unavailable"
- **Rule Type**: Elasticsearch query
- **Query**: `level:error AND (service:postgresql OR service:redis OR service:temporal)`
- **Condition**: `count > 0`
- **Severity**: Critical
- **Action**: Emergency notification

---

## 📊 **HEALTH METRICS**

### **Key Health Indicators (KHIs)**

| **Metric**                | **Target** | **Alert Threshold** | **Measurement**                   |
| ------------------------- | ---------- | ------------------- | --------------------------------- |
| **Container Uptime**      | > 99.9%    | < 99%               | Service availability              |
| **ELK Stack Health**      | 100%       | < 80%               | Elasticsearch, Kibana, Fluent Bit |
| **Resource Usage**        | < 80%      | > 80%               | CPU, memory, disk                 |
| **Log Ingestion Rate**    | Stable     | Drop > 50%          | Log pipeline throughput           |
| **Service Response Time** | < 1s       | > 5s                | Health check response             |
| **Error Rate**            | < 1%       | > 5%                | Service error percentage          |

### **Health Targets**

- **Container Availability**: 99.9% uptime target
- **Resource Utilization**: Keep under 80% for all resources
- **Log Pipeline**: Maintain consistent ingestion rates
- **Service Health**: All services responding within 1 second
- **Error Tolerance**: Less than 1% error rate across all services

---

## 🔧 **TESTING & VALIDATION**

### **Test Script Usage**

```bash
# Test Service Health Dashboard
./infrastructure/scripts/test-service-health-dashboard.sh

# Check service health data
curl -s "http://localhost:9200/dice-logs-*/_search?size=5" | jq '.hits.hits[] | {service: ._source.service, level: ._source.level, component: ._source.component}'

# Monitor real-time health
./infrastructure/scripts/logging-monitor.sh --health --follow
```

### **Validation Checklist**

- [ ] **Container Status**: All services showing correct status
- [ ] **Log Volume**: Service log volumes displaying correctly
- [ ] **ELK Health**: Stack health indicators accurate
- [ ] **Infrastructure Services**: All services properly monitored
- [ ] **Resource Usage**: CPU, memory, disk trends visible
- [ ] **Health Alerts**: All 3 alerts properly configured
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
   - Keep visualizations focused on specific health metrics
   - Use appropriate chart types for data representation
   - Ensure proper color coding for health status

3. **Alert Tuning**:
   - Start with conservative thresholds
   - Monitor alert frequency and adjust as needed
   - Use different severity levels for different health issues

### **Data Quality**

1. **Ensure Consistent Logging**:
   - All services log health metrics
   - Service names and levels are consistent
   - Timestamps are accurate and synchronized

2. **Monitor Data Volume**:
   - Check log ingestion rates
   - Monitor storage usage
   - Implement log rotation if needed

---

## 🎯 **SUCCESS CRITERIA**

### **Implementation Success**

- [ ] **All 6 Visualizations**: Created and displaying data correctly
- [ ] **Dashboard Assembly**: Proper layout and configuration
- [ ] **Alert Configuration**: 3 health alerts active
- [ ] **Data Accuracy**: Health metrics match actual service status
- [ ] **Query Performance**: Dashboard loads within 5 seconds

### **Operational Success**

- [ ] **Real-time Monitoring**: Health issues detected within 1 minute
- [ ] **Alert Response**: DevOps team notified of health degradation
- [ ] **Trend Analysis**: Historical health patterns visible
- [ ] **Capacity Planning**: Resource usage trends identified
- [ ] **Proactive Maintenance**: Health issues resolved before impact

### **Business Value**

- [ ] **Improved Reliability**: Reduced service downtime through proactive monitoring
- [ ] **Faster Issue Resolution**: Health issues identified and resolved quickly
- [ ] **Better Resource Management**: Efficient resource allocation based on usage patterns
- [ ] **Capacity Planning**: Proactive scaling based on health trends
- [ ] **Operational Efficiency**: Automated health monitoring reduces manual effort

---

## 📝 **NEXT STEPS**

### **Immediate Actions**

1. **Create Visualizations**: Follow the step-by-step guide above
2. **Assemble Dashboard**: Combine all visualizations with proper layout
3. **Configure Alerts**: Set up the 3 health alerts
4. **Test Functionality**: Validate all components work correctly
5. **Monitor Performance**: Ensure dashboard queries are fast

### **Ongoing Maintenance**

1. **Regular Review**: Check dashboard performance weekly
2. **Alert Tuning**: Adjust thresholds based on actual health patterns
3. **Data Quality**: Monitor log consistency and completeness
4. **Performance Optimization**: Optimize queries and visualizations as needed

---

**Document Status**: ✅ **READY FOR IMPLEMENTATION**  
**Next Review**: 2025-08-13  
**Owner**: DevOps Team  
**Stakeholders**: Infrastructure, Backend Development Teams
