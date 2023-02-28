(function() {
   function dv(){
      // CAPACITY - Airport arrival ATFM delay - MM - CHART
      var crt_cap_apt_MM = new google.visualization.ChartWrapper({
         chartType: 'ComboChart',
         containerId: 'crt_cap_apt_MM',
         dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1gYIeqeWdcxd7mdXImchbppdI7QvZzp7ucfZdNJbBbyE/edit?usp=sharing&alt=json&sheet=APT_ATFM_MM&range=A1:M73&tq=where%20A%3D1',
         options: {
            //width: 500, height: 300,
            //chartArea: { left: 65, top: 20 },
            chartArea: { left: 50, top: 20, width: '60%', height: '70%' },
            //title: 'Airport Arrival ATFM Delays (monthly)',
            //titleTextStyle : { color: 'grey', fontSize: 12 },
            legend: {
               position: 'right',
               textStyle: { color: 'grey', fontSize: 9 }
            },
            isStacked : 'true',
            series: {
               0: { type: 'bars',  color: '#C0504D' }, //AP Capacity (ATC)
               1: { type: 'bars',  color: '#D99694' }, //AP Staffing (ATC)
               2: { type: 'bars',  color: '#E6B9B8' }, //AP Disruptions (ATC)
               3: { type: 'bars',  color: '#558ED5' }, //AP Capacity (non-ATC)
               4: { type: 'bars',  color: '#B9CDE5' }, //AP Disruptions (non-ATC)
               5: { type: 'bars',  color: '#DCE6F2' }, //AP Events (non-ATC)
               6: { type: 'bars',  color: '#C3D69B' }, //AP Weather
               7: { type: 'lines', color: '#376092', lineWidth: 1, pointShape:'diamond', pointSize: 7 },
               8: { type: 'lines', color: '#777777', lineWidth: 3, lineDashStyle: [6, 3] }
            },
            vAxis: {
               title: 'minutes per arrival',
               titleTextStyle: {
                  color: 'grey',
                  fontSize: 12
               },
               textStyle: { color: 'grey'},
               format: '0.0'
            },
            hAxis: {
               //title: 'Source: PRU Analysis',
               //titleTextStyle: { color: 'grey', fontSize: 10 },
               type: 'string',
               slantedText: true,
               showTextEvery: 1,
               slantedTextAngle: 40,
               textStyle: { fontSize: 11 }
            }
         },
         view: {columns: [1, 4, 5, 6, 8, 9, 10, 7, 11, 12] }
      });
      crt_cap_apt_MM.draw();
   }

   google.setOnLoadCallback(dv);
})();
