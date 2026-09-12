import ballerina/http;
import ballerina/time;

service /assets on new http:Listener(8080) {

    // --- Asset Management (CRUD) --- 

    resource function get .() returns Asset[] {
        // TODO: return assets.toArray()
        return assets.toArray();
    }

    resource function get [string assetTag]() returns http:NotFound & readonly|Asset? {
        // TODO: look up by assetTag, return http:NOT_FOUND if missing
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        return assets[assetTag];
    
    }

    resource function post .(@http:Payload Asset asset) returns Asset|http:Conflict|error {
        // TODO: reject if assetTag already exists (duplicate check -> error handling marks)
        if assets.hasKey(asset.assetTag) {
            return http:CONFLICT; // 409 Conflict
        }
        // Save asset to map and return it
        assets[asset.assetTag] = asset;
        return asset; // 201 Created
    }

    resource function put [string assetTag](@http:Payload Asset updated) returns Asset|http:NotFound|error {
        // TODO: update fields, 404 if assetTag not found
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND; // 404 Not Found
        }
        Asset assetToSave = updated;
        assetToSave.assetTag = assetTag; // Ensure the assetTag remains consistent
        assets[assetTag] = assetToSave;
        return assetToSave;
    }

    resource function delete [string assetTag]() returns http:Ok|http:NotFound {
        // TODO: remove from map
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND; // 404 Not Found
        }
        _ = assets.remove(assetTag);
        return http:OK; // 200 OK
    }

    // --- Filtering ---

    resource function get institution/[string institution]() returns Asset[] {
        // TODO: filter assets.toArray() by institution
        return from Asset asset in assets
               where asset.institution.toLowerAscii() == institution.toLowerAscii()
               select asset;
    }

    resource function get site/[string site]() returns Asset[] {
        // TODO: filter assets.toArray() by site/campus
        return from Asset asset in assets
               where asset.site.toLowerAscii() == site.toLowerAscii()
               select asset;
    }

    // --- Maintenance ---

    resource function get maintenance/overdue() returns Asset[] {
        // TODO: filter schedules where type == MAINTENANCE and dueDate < today
        time:Civil today= time:utcToCivil(time:utcNow());
        string todayStr = string `${today.year}-${today.month < 10 ? "0" : ""}-${today.month}-${today.day < 10 ? "0" : ""}-${today.day}`;   

        return from Asset asset in assets
               where (from Schedule s in asset.schedules
                      where s.'type == "MAINTENANCE" && s.dueDate < todayStr
                      select s).length() > 0
                     select asset;
    }

    // --- Components ---

    resource function post [string assetTag]/components(@http:Payload Component component) returns Asset|http:NotFound|error {
        // TODO: append component to asset.components
            if !assets.hasKey(assetTag) {
                        return http:NOT_FOUND;
            }
                Asset asset = assets.get(assetTag);
            asset.components.push(component);
                assets[assetTag] = asset; // Update the asset in the map
                return asset;
    }

    resource function delete [string assetTag]/components/[string compId]() returns Asset|http:NotFound|error {
        // TODO: remove component by compId
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
    }

    Asset asset = assets.get(assetTag);
    int targetIndex = -1 ;
        foreach int i in 0 ..< asset.components.length() {
            if asset.components[i].compId == compId {
                targetIndex = i;
                break;
            }
        }
    
if targetIndex == -1 {
        return http:NOT_FOUND; // Component not found
}
    _ = asset.components.remove(targetIndex);
    assets[assetTag] = asset; // Update the asset in the map
    return asset;
    }

    // --- Schedules ---

    resource function get [string assetTag]/schedules() returns Schedule[]|http:NotFound & readonly {
        // TODO: return asset.schedules
            if !assets.hasKey(assetTag) {
                return http:NOT_FOUND;
            }
             return assets.get(assetTag).schedules;
    }            

    resource function post [string assetTag]/schedules(@http:Payload Schedule schedule) returns http:NotFound & readonly|Asset {
        // TODO: append schedule to asset.schedules
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        Asset asset = assets.get(assetTag);
        asset.schedules.push(schedule);
        return asset;
    }

    resource function delete [string assetTag]/schedules/[string scheduleId]() returns Asset|http:NotFound|error {
        // TODO: remove schedule by scheduleId
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
    }
     Asset asset = assets.get(assetTag);
    int targetIndex = -1 ;
        foreach int i in 0 ..< asset.schedules.length() {
            if asset.schedules[i].scheduleId == scheduleId {
                targetIndex = i;
                break;
            }
        }
    if targetIndex == -1 {
        return http:NOT_FOUND; // Schedule not found
    }
    _ = asset.schedules.remove(targetIndex);
    assets[assetTag] = asset; // Update the asset in the map
    return asset;
    }
    // --- Work Orders & Tasks ---

    resource function post [string assetTag]/workorders(@http:Payload WorkOrder workOrder) returns Asset|http:NotFound|error {
        // TODO: append work order, default status OPEN
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
    }
    Asset asset = assets.get(assetTag);
    if workOrder.status.trim() == "" {
        workOrder.status = "OPEN";
    }
    asset.workOrders.push(workOrder);
    assets[assetTag] = asset; // Update the asset in the map
    return asset;
    } 

    resource function put [string assetTag]/workorders/[string orderId](@http:Payload WorkOrder updated) returns Asset|http:NotFound|error {
        // TODO: update status/tasks on the matching work order (e.g. close it)
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
    }
    Asset asset = assets.get(assetTag);
    int targetIndex = -1;
    foreach int i in 0 ..< asset.workOrders.length() {
        if asset.workOrders[i].orderId == orderId {
            targetIndex = i;
            break;
        }
    }
    if targetIndex == -1 {
        return http:NOT_FOUND; // Work order not found
    }
    WorkOrder workorder = updated;
    workorder.orderId = orderId; // Ensure the orderId remains consistent
    asset.workOrders[targetIndex] = workorder;
    assets[assetTag] = asset; // Update the asset in the map
    return asset;
    }

    resource function delete [string assetTag]/workorders/[string orderId]() returns Asset|http:NotFound|error {
        // TODO: remove work order by orderId
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
    }
    Asset asset = assets.get(assetTag);
     
     int targetIndex = -1;
    foreach int i in 0 ..< asset.workOrders.length() {
        if asset.workOrders[i].orderId == orderId {
            targetIndex = i;
            break;
        }
    }
    if targetIndex == -1 {
        return http:NOT_FOUND; // Work order not found
    }
    _ = asset.workOrders.remove(targetIndex);
    assets[assetTag] = asset; // Update the asset in the map
    return asset;
}
}   
