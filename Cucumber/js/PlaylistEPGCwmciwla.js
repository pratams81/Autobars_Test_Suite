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
        "provider": "GLOBAL",
        "start": start
      },
      "productRefs": [],
      "provider": "GLOBAL",
      "serviceRef": serviceRef,
      "title": assetTitle,
      "Description": "This is a fake description",
      "Sescription": "This is a fake synopsis"
    };
}

var allProgrammes = {
    programmes: [],
    total_records: 0,
    version: "12345"
};

var tzero = new Date().getTime();
function tPlus(t) {
    return tzero + t*1000*60;
}

var serviceRefs = {
    CNN: "260974830-9568E62E9BFAA2DDA500150D59691876",
    AJ: "251543860-7DA05B1EE4B6D115A2DADB17D200DEFD",
    BBC: "251543837-293EA6543557BB83A012290F27E1E7CB"
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
    ]
};

if(localStorage.allProgrammes) {
  allProgrammes = JSON.parse(window.localStorage.allProgrammes);
} else {
  Object.keys(serviceRefs).forEach(function(channel) {
      var serviceEvents = data[channel];
      serviceEvents.forEach(function(ev, i) {
          var serviceRef = serviceRefs[channel];
          allProgrammes.programmes.push(generateProgramme(serviceRef, channel + " " + i, tPlus(ev.start), ev.duration));
      });
  });

  allProgrammes.programmes = allProgrammes.programmes.sort(function byStartAscending(a, b) {
      return a.period.start - b.period.start;
  });

  allProgrammes.total_records = allProgrammes.programmes.length;

  window.localStorage.setItem('allProgrammes', JSON.stringify(allProgrammes));
}

var bbc0 = allProgrammes.programmes.find(function(p) {
  return p.Title === "BBC 0";
});

XMLHttpRequest.register("GET", "*/metadata/delivery/GLOBAL/btv/programmes*" + bbc0.id + "*", function(req) {
  this.json({
    programmes: [bbc0],
    version: "12346",
    total_records: 1
  });
});

/**
 * Capture a call to programmes
 */
XMLHttpRequest.register("GET", "*/metadata/delivery/GLOBAL/btv/programmes*period.start*period.end*sort*period.start*", function(req) {
    this.json(allProgrammes);
});
