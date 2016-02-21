// Ensure all programmes have no contentRef
XMLHttpRequest.register("GET", "*/metadata/delivery/*/btv/programmes?*", function(req) {
    this.intercept(req, function() {
        var response = JSON.parse(this.responseText);

        // Set an arbitrary ID so there's no chance
        response.programmes.forEach(function(programme) {
            programme.isStartOver = true;
            programme.isCatchUp = true;
            delete programme.contentRef;
        });

        this.json(response);
    });
});

// Force any requests for editorials to come back with no records
// Should only be installed once the browse page has been fully loaded
XMLHttpRequest.register("GET", '*/metadata/delivery/*/vod/editorials?*', function(req) {
    this.intercept(req, function() {
        var response = JSON.parse(this.responseText);

        this.json({
          "editorials": [],
          "total_records": 0,
          "version": "20150915202023"
        });
    });
});
