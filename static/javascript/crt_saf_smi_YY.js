(function() {
   function dv() {
// SAFETY - Separation minima infringements - YY - CHART
      var crt_saf_smi_YY = new google.visualization.ChartWrapper({
         chartType: 'ComboChart',
         containerId: 'crt_saf_smi_YY',
         dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1qChhA2bkwkIv5B70cFNOEs4ubuP1xE2gceWcfAJozcg/gviz/tq?sheet=SMI&range=A5:F18&headers=1&tq=',
         options: {
            chartArea: { left: 50, top: 40, width: '75%', height: '60%' },
            legend: {
               position: 'top',
               maxLines: 2,
               textStyle: {color: 'grey', fontSize: 10 }
            },
            isStacked : 'true',
            series: {
               0: { type: 'lines', color:'darkgrey', lineWidth: 1, pointSize: 6,targetAxisIndex: 0 },
               1: { type: 'lines', color:'#5D7CBA', lineWidth: 1, pointSize: 6,targetAxisIndex: 1 },
               2: { type: 'bars', color:'#376092', targetAxisIndex: 0 },
               3: { type: 'bars', color:'#B9CDE5', targetAxisIndex: 0 }
            },
            vAxes:{
               0: {
                  title:'count',
                  titleTextStyle: { color: 'grey', fontSize: 11 },
                  textStyle: { color: 'grey' }
               },
               1: {
                  title: 'reported SMIs',
                  titleTextStyle: { color: '#5D7CBA', fontSize: 11 },
                  textStyle: { color:'#5D7CBA' }
               }
            },
            hAxis: {
               type: 'string',
               textStyle: { fontSize: 11 }
            }
         },
         view: {columns: [0, 1, 2, 4, 5], rows: [3,4,5,6,7,8,9,10,11,12] }
      });
      crt_saf_smi_YY.draw();
   }

   google.setOnLoadCallback(dv);
})();  