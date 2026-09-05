import ballerina/http;

// In-memory store, keyed by assetTag (the assignment's required unique key)
map<Asset> assets = {};

service /assets on new http:Listener(8080) {

    // --- Asset Management (CRUD) ---

    resource function get .() returns Asset[] {
        // TODO: return assets.toArray()
    }

    resource function get [string assetTag]() returns Asset|http:NotFound {
        // TODO: look up by assetTag, return http:NOT_FOUND if missing
    }

    resource function post .(@http:Payload Asset asset) returns Asset|http:Conflict|error {
        // TODO: reject if assetTag already exists (duplicate check -> error handling marks)
    }

    resource function put [string assetTag](@http:Payload Asset updated) returns Asset|http:NotFound|error {
        // TODO: update fields, 404 if assetTag not found
    }

    resource function delete [string assetTag]() returns http:Ok|http:NotFound {
        // TODO: remove from map
    }

    // --- Filtering ---

    resource function get institution/[string institution]() returns Asset[] {
        // TODO: filter assets.toArray() by institution
    }

    resource function get site/[string site]() returns Asset[] {
        // TODO: filter assets.toArray() by site/campus
    }

    // --- Maintenance ---

    resource function get maintenance/overdue() returns Asset[] {
        // TODO: filter schedules where type == MAINTENANCE and dueDate < today
    }

    // --- Components ---

    resource function post [string assetTag]/components(@http:Payload Component component) returns Asset|http:NotFound|error {
        // TODO: append component to asset.components
    }

    resource function delete [string assetTag]/components/[string compId]() returns Asset|http:NotFound|error {
        // TODO: remove component by compId
    }

    // --- Schedules ---

    resource function get [string assetTag]/schedules() returns Schedule[]|http:NotFound {
        // TODO: return asset.schedules
    }

    resource function post [string assetTag]/schedules(@http:Payload Schedule schedule) returns Asset|http:NotFound|error {
        // TODO: append schedule to asset.schedules
    }

    resource function delete [string assetTag]/schedules/[string scheduleId]() returns Asset|http:NotFound|error {
        // TODO: remove schedule by scheduleId
    }

    // --- Work Orders & Tasks ---

    resource function post [string assetTag]/workorders(@http:Payload WorkOrder workOrder) returns Asset|http:NotFound|error {
        // TODO: append work order, default status OPEN
    }

    resource function put [string assetTag]/workorders/[string orderId](@http:Payload WorkOrder updated) returns Asset|http:NotFound|error {
        // TODO: update status/tasks on the matching work order (e.g. close it)
    }

    resource function delete [string assetTag]/workorders/[string orderId]() returns Asset|http:NotFound|error {
        // TODO: remove work order by orderId
    }
}
