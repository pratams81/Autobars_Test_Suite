/*
 * BTV Device Sensitive License Checks
 * With this change, services are provided with products
 * These products also have deviceTypes allowing us to filter on deviceType
 * (not technical.deviceType)
 */

// The headend supports DSLC. Alter the product for a single service so that we can
// distinguish whether we successfully fetched products, rather than productRefs
XMLHttpRequest.register("GET", "*/metadata/delivery/GLOBAL/btv/services*", function(req) {
    this.intercept(req, function(x) {
        var response = JSON.parse(this.responseText);
        response.services.forEach(function(s) {
      		/* Modify RTS Deux, this channel will show as unsubscribed if
               DSLC are used */
    		if (s.editorial.longName === "RTS Deux - The swiss channel") {
    			s.technical.products = [{
        			id: "NotSubscribed" /* Unsubscribed products */
        		}, {
        			id: "AlsoNotSubscribed"
        		}];
    		}
        });
        this.json(response);
    });
});
