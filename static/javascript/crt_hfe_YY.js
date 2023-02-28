(function() {
   function dv() {
      // ENVIRONMENT - Horizontal flight efficiency - YY - CHART
      var crt_hfe_YY = new google.visualization.ChartWrapper({
         chartType: 'ComboChart',
         containerId: 'crt_hfe_YY',
         dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1KgOIBF93axvXD6ENQYvEsWHqnA8eW_RvGV4EQlGava4/edit?usp=sharing&sheet=HFE_YY&range=A1:D13',
            options: {
              // width: 500, height: 300,
               chartArea: { left: 85, top: 60, width: '55%' },
               //title: 'Horizontal En-route Flight Efficiency (yearly)',
               //titleTextStyle: { color: 'grey', fontSize: 14 },
               legend: {
                  position: 'right',
                  textStyle: { color: 'grey', fontSize: 10 }
               },
               series: {
                        0: {
                           type: 'lines',
                           color:'#5D7CBA',
                           lineWidth: 1,
                           pointSize: 6
                        },
                        1: {
                           type: 'lines',
                           color: '#C0504D',
                           lineWidth: 1,
                           pointShape: 'diamond',
                           pointSize: 8
                        },
                        2: {
                           type: 'lines',
                           color: 'green',
                           lineWidth: 1,
                           pointShape: 'triangle',
                           pointSize: 8
                        }
                     },
               vAxis: {
                  title: 'Efficiency (%)',
                  titleTextStyle: { color: 'grey', fontSize: 10 },
                  //minValue: 0.0,
                  //maxValue: 1.0,
                  //viewWindow: { min: 0.95, max: 1.0 },
                  format: '0.0%'
               },
               hAxis: {
                  titleTextStyle: { color: 'grey', fontSize: 10 }
               }
            },
            view: { columns: [0, 1, 2, 3] }
         }
      );
      crt_hfe_YY.draw();
   }

   google.setOnLoadCallback(dv);
})();
