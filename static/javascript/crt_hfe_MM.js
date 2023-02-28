(function() {
   function dv() {
      // ENVIRONMENT - Horizontal flight efficiency - MM - CHART
      var crt_hfe_MM = new google.visualization.ChartWrapper(
         {
            chartType: 'LineChart',
            containerId: 'crt_hfe_MM',
            dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1KgOIBF93axvXD6ENQYvEsWHqnA8eW_RvGV4EQlGava4/edit?usp=sharing&sheet=HFE_MM&range=A1:J73&tq=where%20A%3D1',
            options: {
               //'width': 500, 'height': 300,
               chartArea: { left: 85, top: 30, width: '55%' },
                 // title: 'Horizontal En-route Flight Efficiency (monthly)',
                 // titleTextStyle: { color: 'grey', fontSize: 14 },
                  legend: {
                     position: 'right',
                     textStyle: { color: 'grey', fontSize: 10 }
                  },
                  series: {
                     0: {
                        type: 'lines',
                        color: '#5D7CBA',
                        lineWidth: 1,
                        pointSize: 4
                     },
                     1: {
                        type: 'lines',
                        color: '#C0504D',
                        lineWidth: 1,
                        pointSize: 4,
                        pointShape: 'diamond'
                     },
                     2: {
                        type: 'lines',
                        color: '#5D7CBA',
                        lineWidth: 2,
                        pointSize: 4,
                        lineDashStyle: [6, 3]
                     },
                     3: {
                        type: 'lines',
                        color:'#C0504D',
                        lineWidth: 2,
                        pointSize: 4,
                        lineDashStyle: [6, 3],
                        pointShape:'diamond'
                     },
                     4: {
                        type: 'lines',
                        color:'green',
                        lineWidth: 2,
                        pointSize: 4,
                        
                     },
                     5: {
                        type: 'lines',
                        color:'green',
                        lineWidth: 2,
                        pointSize: 4,
                        lineDashStyle: [6, 3],
                        pointShape:'diamond'
                     }

                  },
               vAxis: {
                  title: 'Efficiency (%)',
                  titleTextStyle: { color: 'grey', fontSize: 10 },
                  format: '0.0%'
               },
               hAxis: {
                  titleTextStyle: { color: 'grey', fontSize: 10 },
                  type: 'string',
                  slantedText: true,
                  slantedTextAngle: 40,
                  textStyle: { fontSize: 11 }
               }
            },
            view: { 'columns': [1, 2, 3, 6, 7, 8, 9] }
         }
      );
      crt_hfe_MM.draw();
   }

   google.setOnLoadCallback(dv);
})();
