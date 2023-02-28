(function() {
   function dv() {
// SAFETY - ATM Specific Technical Events - YY - CHART [EU_YY]
      var crt_saf_aso_YY = new google.visualization.ChartWrapper({
         chartType: 'ComboChart',
         containerId: 'crt_saf_aso_YY',
         dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1qChhA2bkwkIv5B70cFNOEs4ubuP1xE2gceWcfAJozcg/edit?usp=sharing&sheet=ASO&range=A5:H18',
         options: {
            titleTextStyle : { color: 'grey', fontSize: 12 },
            chartArea: { left: 50, top: 40, width: '75%', height: '60%' },
            legend: {
               position: 'top',
               maxLines: 3,
               textStyle: { color: 'grey', fontSize: 10 }
            },
            isStacked : 'true',
            series: {
               2: { type: 'bars', color: '#B9CDE5' },
               1: { type: 'bars', color: '#376092' },
               0: { type: 'bars', color: '#C0504D' }
            },
            vAxis: {
               title: 'count',
               titleTextStyle: { color: 'grey', fontSize: 11 },
               textStyle: { color: 'grey' }
            },
            hAxis: {
               type: 'string',
               textStyle: { fontSize: 11 }
            }
         },
         view: { columns: [0, 7, 6, 5], rows: [3,4,5,6,7,8,9,10,11,12]  }
      });
      crt_saf_aso_YY.draw();
   }

   google.setOnLoadCallback(dv);
})();