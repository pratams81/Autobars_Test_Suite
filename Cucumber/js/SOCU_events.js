XMLHttpRequest.register("GET", "*/metadata/delivery/*/btv/programmes?*", function(req) {
    this.intercept(req, function() {
        var response = JSON.parse(this.responseText);

        response.programmes.forEach(function(programme) {
            programme.isStartOver = true;
            programme.isCatchUp = true;
        });

        this.json(response);
    });
});
