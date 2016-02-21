XMLHttpRequest.register("GET", "*/metadata/delivery/*/btv/programmes?*", function(req) {
    this.intercept(req, function() {
        var response = JSON.parse(this.responseText);

        // Add a contentRef to all programmes fetched
        response.programmes.forEach(function(programme) {
            programme.isStartOver = true;
            programme.isCatchUp = true;
            programme.contentRef = "FAKECONTENT";
        });

        this.json(response);
    });
});

XMLHttpRequest.register("GET", '*/metadata/delivery/*/vod/editorials?*' + encodeURIComponent('"editorial.id":"FAKECONTENT"') + '*', function(req) {
    this.intercept(req, function() {
        var response = JSON.parse(this.responseText);

        this.json({
          "editorials": [
            {
              "Images": [],
              "ProgramId": "LYS003215051",
              "ProgrammeEndDate": "2015-09-17T15:30:00Z",
              "ProgrammeStartDate": "2015-09-17T14:30:00Z",
              "Rating": {
                "Title": "Undefined",
                "code": "0",
                "precedence": 0
              },
              "ServiceLongName": "socu3",
              "ShortTitle": "ContentRef",
              "Title": "ContentRef",
              "_id": "LYS003215504",
              "companyId": "GLOBAL",
              "deviceType": [],
              "duration": 3600,
              "id": "LYS003215504",
              "media": {},
              "nls": {
                "Title": "2b372b3d374b3f43086104514f2f3d4d27042d37044b4527334127011e018f7d8f7d8f0900"
              },
              "provider": "B1",
              "seriesRef": "",
              "technicals": [
                {
                  "ProgramId": "LYS003215051",
                  "ProgrammeEndDate": "2015-09-17T15:30:00Z",
                  "ProgrammeStartDate": "2015-09-17T14:30:00Z",
                  "Rating": {
                    "Title": "Undefined",
                    "code": "0",
                    "precedence": 0
                  },
                  "ServiceLongName": "socu3v",
                  "ShortTitle": "Ciclismo: Vuelta di Spagna",
                  "Title": "Ciclismo: Vuelta di Spagna",
                  "_id": "LYS003215505",
                  "companyId": "GLOBAL",
                  "deviceType": [
                    "PC_CLEAR",
                    "TABLET_CLEAR",
                    "STB",
                    "TABLET",
                    "PHONE",
                    "Default",
                    "PC",
                    "STB_CLEAR",
                    "Super",
                    "PHONE_CLEAR"
                  ],
                  "duration": 3600,
                  "id": "LYS003215505",
                  "mainContentRef": "LYS003215504",
                  "media": {
                    "AV_HarmonicOSPlaylistName": {
                      "drmId": "1222",
                      "drmInstanceName": "PRM_Nagra",
                      "fileName": "http://nagra.com/contentRef.m3u8",
                      "format": "AV_HarmonicOSPlaylistName",
                      "frameDuration": 0,
                      "id": "LYS003215507"
                    }
                  },
                  "nls": {
                    "Title": "2b372b3d374b3f43086104514f2f3d4d27042d37044b4527334127011e018f7d8f7d8f0900"
                  },
                  "products": [
                    {
                      "TitleForProduct": "catchup subscription",
                      "_id": "LYS000195370",
                      "deviceType": [],
                      "endPurchase": 2114377200.0,
                      "endValidity": 2145913200.0,
                      "id": "LYS000195370",
                      "platformRef": "LYS000000107",
                      "price": {
                        "billingInterval": "1",
                        "billingTimeUnit": "year",
                        "currency": "EUR",
                        "endPurchase": 2114377200.0,
                        "startPurchase": 1386339892.0,
                        "subscriptionDurationRatio": "1",
                        "value": 0.0
                      },
                      "provider": "B1",
                      "regions": [
                        "ACCESSPOINT1"
                      ],
                      "rentalDuration": "0",
                      "startPurchase": 1386339892.0,
                      "startValidity": 1386339892.0,
                      "title": "catchcup subscription",
                      "type": "subscription",
                      "voditems": [
                        {
                          "_id": "LYS003215506",
                          "contentRef": "LYS003215505",
                          "deviceType": [],
                          "id": "LYS003215506",
                          "nodeRefs": [
                            "LYS000497584"
                          ],
                          "period": {
                            "duration": 86400,
                            "end": 1442590260.0,
                            "start": 1442503860.0
                          },
                          "previewDate": 1442503860.0,
                          "provider": "B1",
                          "publishToEndUserDevices": true,
                          "title": "CU-2776031-874-Ciclismo: Vuelta di Spagna",
                          "type": "catchup"
                        }
                      ]
                    }
                  ],
                  "profileRef": "LYS000497387",
                  "provider": "B1",
                  "seriesRef": "",
                  "title": "CU-2776031-874-Ciclismo: Vuelta di Spagna"
                }
              ],
              "title": "CU-2776031-873-Ciclismo: Vuelta di Spagna"
            }
          ],
          "total_records": 1,
          "version": "20150915202023"
        });
    });
});
