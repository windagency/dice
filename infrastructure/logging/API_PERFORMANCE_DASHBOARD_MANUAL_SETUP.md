# API Performance Dashboard Manual Setup Guide

**Version**: 1.0 - API Performance Monitoring  
**Created**: 2025-08-06 18:10 BST  
**Status**: 🚧 **READY FOR MANUAL IMPLEMENTATION**  
**Priority**: HIGH - Real-time API performance monitoring

---

## 🎯 **DASHBOARD OVERVIEW**

The API Performance Dashboard provides comprehensive monitoring of backend API performance, including response times, error rates, request volumes, and database query performance. This dashboard is essential for maintaining optimal API performance and identifying performance bottlenecks.

### **Key Metrics Monitored**

- **Response Time Percentiles**: P50, P95, P99 response times
- **Error Rate by Endpoint**: Status code distribution and error patterns
- **Request Volume Trends**: API usage patterns and traffic analysis
- **Database Query Performance**: Slow query identification and optimization
- **Service Health Indicators**: Uptime and health check status

---

## 📊 **DASHBOARD COMPONENTS**

### **1. Response Time Percentiles Visualization**

**Type**: Line Chart  
**Purpose**: Monitor P50, P95, P99 response times over time

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Line** chart
   - Choose **dice-performance-*** index pattern

2. **Configure Y-axis (Multiple Metrics)**:
   - **Metric 1**: Percentile
     - **Aggregation**: Percentiles
     - **Field**: `metadata.duration`
     - **Percentile**: 50
     - **Custom Label**: "P50 Response Time"
   
   - **Metric 2**: Percentile
     - **Aggregation**: Percentiles
     - **Field**: `metadata.duration`
     - **Percentile**: 95
     - **Custom Label**: "P95 Response Time"
   
   - **Metric 3**: Percentile
     - **Aggregation**: Percentiles
     - **Field**: `metadata.duration`
     - **Percentile**: 99
     - **Custom Label**: "P99 Response Time"

3. **Configure X-axis**:
   - **Aggregation**: Date Histogram
   - **Field**: `@timestamp`
   - **Interval**: Auto
   - **Custom Label**: "Time"

4. **Add Filter**:
   - **Field**: `metadata.duration`
   - **Operator**: exists
   - **Label**: "Performance Data Only"

5. **Save Visualization**:
   - **Title**: "API Response Time Percentiles"
   - **Description**: "P50, P95, P99 response times over time"

### **2. Error Rate by Endpoint Visualization**

**Type**: Vertical Bar Chart  
**Purpose**: Monitor error rates and status code distribution by endpoint

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Vertical Bar** chart
   - Choose **dice-performance-*** index pattern

2. **Configure Y-axis**:
   - **Aggregation**: Count
   - **Custom Label**: "Request Count"

3. **Configure X-axis**:
   - **Aggregation**: Terms
   - **Field**: `metadata.endpoint`
   - **Size**: 10
   - **Custom Label**: "API Endpoints"

4. **Add Split Series**:
   - **Sub Aggregation**: Terms
   - **Field**: `metadata.statusCode`
   - **Size**: 5
   - **Custom Label**: "Status Codes"

5. **Add Filter**:
   - **Field**: `metadata.statusCode`
   - **Operator**: is greater than
   - **Value**: 299
   - **Label**: "Error Status Codes Only"

6. **Save Visualization**:
   - **Title**: "Error Rate by Endpoint"
   - **Description**: "Error distribution by API endpoint"

### **3. Request Volume Trends Visualization**

**Type**: Area Chart  
**Purpose**: Monitor API usage patterns and traffic trends

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Area** chart
   - Choose **dice-performance-*** index pattern

2. **Configure Y-axis**:
   - **Aggregation**: Count
   - **Custom Label**: "Request Volume"

3. **Configure X-axis**:
   - **Aggregation**: Date Histogram
   - **Field**: `@timestamp`
   - **Interval**: 1 hour
   - **Custom Label**: "Time"

4. **Add Split Series**:
   - **Sub Aggregation**: Terms
   - **Field**: `metadata.endpoint`
   - **Size**: 5
   - **Custom Label**: "Endpoints"

5. **Add Filter**:
   - **Field**: `metadata.endpoint`
   - **Operator**: exists
   - **Label**: "Valid Endpoints Only"

6. **Save Visualization**:
   - **Title**: "Request Volume Trends"
   - **Description**: "API request volume trends by endpoint"

### **4. Database Query Performance Visualization**

**Type**: Data Table  
**Purpose**: Monitor slow database queries and performance issues

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Data Table**
   - Choose **dice-performance-*** index pattern

2. **Configure Metrics**:
   - **Metric 1**: Average
     - **Aggregation**: Average
     - **Field**: `metadata.duration`
     - **Custom Label**: "Avg Duration"
   
   - **Metric 2**: Count
     - **Aggregation**: Count
     - **Custom Label**: "Request Count"

3. **Configure Buckets**:
   - **Split Rows**:
     - **Aggregation**: Terms
     - **Field**: `metadata.endpoint`
     - **Size**: 10
     - **Custom Label**: "Endpoint"

4. **Add Filter**:
   - **Field**: `metadata.duration`
   - **Operator**: is greater than
   - **Value**: 1000
   - **Label**: "Slow Queries (>1s)"

5. **Save Visualization**:
   - **Title**: "Database Query Performance"
   - **Description**: "Slow database queries and performance analysis"

### **5. Service Health Indicators Visualization**

**Type**: Gauge Chart  
**Purpose**: Monitor service health and uptime status

#### **Configuration Steps**

1. **Create Visualization**:
   - Go to **Analytics** → **Visualizations**
   - Click **Create visualization**
   - Select **Gauge**
   - Choose **dice-performance-*** index pattern

2. **Configure Metrics**:
   - **Aggregation**: Average
   - **Field**: `metadata.duration`
   - **Custom Label**: "Avg Response Time"

3. **Configure Gauge Settings**:
   - **Min**: 0
   - **Max**: 5000
   - **Thresholds**:
     - **Green**: 0-1000ms
     - **Yellow**: 1000-3000ms
     - **Red**: 3000-5000ms

4. **Add Filter**:
   - **Field**: `metadata.statusCode`
   - **Operator**: is
   - **Value**: 200
   - **Label**: "Successful Requests Only"

5. **Save Visualization**:
   - **Title**: "Service Health Indicators"
   - **Description**: "API service health and response time monitoring"

---

## 🏗️ **DASHBOARD ASSEMBLY**

### **Step 1: Create Dashboard**

1. **Navigate to Dashboards**:
   - Go to **Analytics** → **Dashboards**
   - Click **Create dashboard**

2. **Add Visualizations**:
   - Click **Add** → **Add panels**
   - Add all 5 visualizations:
     - API Response Time Percentiles
     - Error Rate by Endpoint
     - Request Volume Trends
     - Database Query Performance
     - Service Health Indicators

### **Step 2: Configure Layout**

**Recommended Layout**:
- **Row 1**: Response Time Percentiles (full width)
- **Row 2**: Error Rate by Endpoint (left) + Service Health Indicators (right)
- **Row 3**: Request Volume Trends (full width)
- **Row 4**: Database Query Performance (full width)

### **Step 3: Dashboard Settings**

1. **Time Range**: Last 24 hours
2. **Auto-refresh**: Every 30 seconds
3. **Global Filters**:
   - **Service**: `service:backend-api`
   - **Performance Data**: `metadata.duration:>0`

### **Step 4: Save Dashboard**

- **Title**: "API Performance Dashboard"
- **Description**: "Comprehensive API performance monitoring with response times, error rates, and health indicators"

---

## 🚨 **PERFORMANCE ALERTS**

### **Alert 1: High Response Time Alert**

**Configuration**:
- **Name**: "High API Response Time"
- **Rule Type**: Elasticsearch query
- **Query**: `metadata.duration:>2000`
- **Condition**: `count > 5 per minute`
- **Severity**: Medium
- **Action**: Notify DevOps team

### **Alert 2: High Error Rate Alert**

**Configuration**:
- **Name**: "High API Error Rate"
- **Rule Type**: Elasticsearch query
- **Query**: `metadata.statusCode:>299`
- **Condition**: `rate > 0.05 for 5 minutes`
- **Severity**: High
- **Action**: Immediate notification

### **Alert 3: Service Health Degradation**

**Configuration**:
- **Name**: "Service Health Degradation"
- **Rule Type**: Elasticsearch query
- **Query**: `metadata.statusCode:500`
- **Condition**: `count > 0`
- **Severity**: Critical
- **Action**: Emergency notification

---

## 📊 **PERFORMANCE METRICS**

### **Key Performance Indicators (KPIs)**

| **Metric**            | **Target** | **Alert Threshold** | **Measurement**       |
| --------------------- | ---------- | ------------------- | --------------------- |
| **P50 Response Time** | < 500ms    | > 1000ms            | 95th percentile       |
| **P95 Response Time** | < 1000ms   | > 2000ms            | 95th percentile       |
| **P99 Response Time** | < 2000ms   | > 5000ms            | 99th percentile       |
| **Error Rate**        | < 1%       | > 5%                | Percentage of 4xx/5xx |
| **Request Volume**    | Stable     | > 200% baseline     | Requests per minute   |
| **Service Uptime**    | > 99.9%    | < 99%               | Health check status   |

### **Performance Targets**

- **Response Time**: 95% of requests under 1 second
- **Error Rate**: Less than 1% of requests result in errors
- **Availability**: 99.9% uptime target
- **Throughput**: Handle 1000+ requests per minute

---

## 🔧 **TESTING & VALIDATION**

### **Test Script Usage**

```bash
# Test API Performance Dashboard
./infrastructure/scripts/test-api-performance-dashboard.sh

# Check performance data
curl -s "http://localhost:9200/dice-performance-*/_search?size=5" | jq '.hits.hits[] | {duration: ._source.metadata.duration, endpoint: ._source.metadata.endpoint, statusCode: ._source.metadata.statusCode}'

# Monitor real-time performance
./infrastructure/scripts/logging-monitor.sh --performance --follow
```

### **Validation Checklist**

- [ ] **Response Time Percentiles**: P50, P95, P99 displaying correctly
- [ ] **Error Rate Visualization**: Error distribution by endpoint visible
- [ ] **Request Volume Trends**: Traffic patterns showing correctly
- [ ] **Database Performance**: Slow queries identified
- [ ] **Health Indicators**: Service status accurately reflected
- [ ] **Alerts Configuration**: All 3 alerts properly configured
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
   - Keep visualizations focused on specific metrics
   - Use appropriate chart types for data representation
   - Ensure proper color coding for severity levels

3. **Alert Tuning**:
   - Start with conservative thresholds
   - Monitor alert frequency and adjust as needed
   - Use different severity levels for different response times

### **Data Quality**

1. **Ensure Consistent Logging**:
   - All API endpoints log performance metrics
   - Duration and status codes are always present
   - Timestamps are accurate and consistent

2. **Monitor Data Volume**:
   - Check log ingestion rates
   - Monitor storage usage
   - Implement log rotation if needed

---

## 🎯 **SUCCESS CRITERIA**

### **Implementation Success**

- [ ] **All 5 Visualizations**: Created and displaying data correctly
- [ ] **Dashboard Assembly**: Proper layout and configuration
- [ ] **Alert Configuration**: 3 performance alerts active
- [ ] **Data Accuracy**: Performance metrics match actual API behavior
- [ ] **Query Performance**: Dashboard loads within 5 seconds

### **Operational Success**

- [ ] **Real-time Monitoring**: Performance issues detected within 2 minutes
- [ ] **Alert Response**: DevOps team notified of performance degradation
- [ ] **Trend Analysis**: Historical performance patterns visible
- [ ] **Capacity Planning**: Resource usage trends identified
- [ ] **Optimization Insights**: Slow endpoints and queries identified

### **Business Value**

- [ ] **Improved Response Times**: API performance optimized based on dashboard insights
- [ ] **Reduced Downtime**: Proactive issue detection and resolution
- [ ] **Better User Experience**: Faster API responses and fewer errors
- [ ] **Resource Optimization**: Efficient resource allocation based on usage patterns
- [ ] **Capacity Planning**: Proactive scaling based on traffic trends

---

## 📝 **NEXT STEPS**

### **Immediate Actions**

1. **Create Visualizations**: Follow the step-by-step guide above
2. **Assemble Dashboard**: Combine all visualizations with proper layout
3. **Configure Alerts**: Set up the 3 performance alerts
4. **Test Functionality**: Validate all components work correctly
5. **Monitor Performance**: Ensure dashboard queries are fast

### **Ongoing Maintenance**

1. **Regular Review**: Check dashboard performance weekly
2. **Alert Tuning**: Adjust thresholds based on actual usage patterns
3. **Data Quality**: Monitor log consistency and completeness
4. **Performance Optimization**: Optimize queries and visualizations as needed

---

**Document Status**: ✅ **READY FOR IMPLEMENTATION**  
**Next Review**: 2025-08-13  
**Owner**: DevOps Team  
**Stakeholders**: Backend Development, Infrastructure Teams
