/*
   This fake generates data for playlist tests
   It is valid only for the current day of data
 */

var eventId = 1;

function generateProgramme(serviceRef, assetTitle, start, duration) {
    // Convert down to seconds
    start /= 1000;
    // Convert duration back from minutes
    duration *=  60;

    return {
      "Rating": {
        "Title": "Undefined",
        "code": "0",
        "precedence": 0
      },
      "ShortTitle": assetTitle,
      "Title": assetTitle,
      "deviceType": [],
      "eventId": eventId++,
      "id": "LYS" + Math.random(),
      "locale": "en_GB",
      "nls": {
        "Title": "29373d3727492d430861044d4349412f430437414d2f49412759374341273d2f0123018f7d8f808f1100"
      },
      "period": {
        "duration": duration,
        "end": start+duration,
        "provider": "B1",
        "start": start
      },
      "productRefs": [],
      "provider": "B1",
      "serviceRef": serviceRef,
      "title": assetTitle,
      "description": "This is a fake description"
    };
}

var response = {
    programmes: [],
    total_records: 0,
    version: "12345"
};

var tzero = new Date().getTime();
function tPlus(t) {
    return tzero + t*1000*60;
}

var serviceRefs = {
    CNN: "ENVIVIO_CH1_M",
    AJ: "ENVIVIO_CH2_M",
    BBC: "ENVIVIO_CH3_M",
    Euronews: "ENVIVIO_CH5_M",
    Eurosport: "HARMONIC_CH7M"
};

// Start time will be 12pm, start: 3*60 = 3pm (15:00)
var data = {
    CNN: [
        { start: 0, duration: 60 }, // 12:00, 1 hour
        { start: 60, duration: 2*60 }, // 13:00, 2 hours
        { start: 3*60, duration: 60 }, // 15:00, 1 hour
        { start: 4*60, duration: 12*60 } // 16:00, 12 hours
    ],
    AJ: [
        { start: 0, duration: 30 }, // 12:00, 30 mins
        { start: 30, duration: 30 }, // 12:30,  30 mins
        { start: 60, duration: 20 }, // 13:00, 20 mins
        { start: 80, duration: 6*60 }, // 13:20, 6 hours
        { start: 440, duration: 20 } // 19:20, 20 mins
    ],
    BBC: [
        { start: 0, duration: 30 }, // 12:00, 30 mins
        { start: 30, duration: 60 }, // 12:30, 1 hour
        { start: 90, duration: 60 }, // 13:30, 1 hour
        { start: 150, duration: 20 }, // 14:30, 20 mins
    ],
    Euronews: [
        // fill me in
    ],
    Eurosport: [
        // fill me in
    ]
};

Object.keys(serviceRefs).forEach(function(channel) {
    var serviceEvents = data[channel];
    serviceEvents.forEach(function(ev, i) {
        var serviceRef = serviceRefs[channel];
        response.programmes.push(generateProgramme(serviceRef, channel + " " + i, tPlus(ev.start), ev.duration));
    });
});

response.programmes = response.programmes.sort(function byStartAscending(a, b) {
    return a.period.start - b.period.start;
});

response.total_records = response.programmes.length;

/**
 * Capture a call to programmes
 */
XMLHttpRequest.register("GET", "*/metadata/delivery/B1/btv/programmes*period.start*period.end*sort*period.start*", function(req) {
    this.json(response);
});
