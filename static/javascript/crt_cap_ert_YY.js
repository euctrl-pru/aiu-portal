(function() {
   function dv() {
      // CAPACITY - En-route ATFM delay - YY - CHART
      var crt_cap_ert_YY = new google.visualization.ChartWrapper({
         chartType: 'ComboChart',
         containerId: 'crt_cap_ert_YY',
         dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1g_EclskD6qP8b_aYYhW3xrng616ZysYW5WVtGD9pOXk/edit?usp=sharing&alt=json&sheet=ERT_ATFM_YY&range=A1:I13',
         options: {
            //width: 500, height: 300,
            //chartArea: { left: 65, top: 20 },
            chartArea: { left: 50, top: 20, width: '60%', height: '70%' },
            //title: 'En-route ATFM Delays (yearly)',
            //titleTextStyle: { color: 'grey', fontSize: 12 },
            legend: {
               position: 'right',
               textStyle: { color: 'grey', fontSize: 9 }
            },
            isStacked: 'true',
            series: {
               0: { type: 'bars',  color: '#C0504D', targetAxisIndex: 0 }, //ER Capacity (ATC)
               1: { type: 'bars',  color: '#D99694', targetAxisIndex: 0 }, //ER Staffing (ATC)
               2: { type: 'bars',  color: '#E6B9B8', targetAxisIndex: 0 }, //ER Disruptions (ATC)
               3: { type: 'bars',  color: '#558ED5', targetAxisIndex: 0 }, //ER Capacity (non-ATC)
               4: { type: 'bars',  color: '#B9CDE5', targetAxisIndex: 0 }, //ER Disruptions (non-ATC)
               5: { type: 'bars',  color: '#DCE6F2', targetAxisIndex: 0 }, //ER Events (non-ATC)
               6: { type: 'bars',  color: '#C3D69B', targetAxisIndex: 0 } //ER Weather
            },
            vAxis: {
               title: 'minutes per flight',
               format: '0.0',
               titleTextStyle: { color: 'grey', fontSize: 12 },
               textStyle: { color: 'grey' }
            },
            hAxis: {
               slantedText: true,
               slantedTextAngle: 40,
               showTextEvery: 1,
               //title: 'Source: PRU Analysis; NM',
               //titleTextStyle: { color: 'grey', fontSize: 10 }
            }
         },
         view: { columns: [0, 2, 3, 4, 5, 6, 7, 8] }
      });
      crt_cap_ert_YY.draw();
   }

   google.setOnLoadCallback(dv);
})();
