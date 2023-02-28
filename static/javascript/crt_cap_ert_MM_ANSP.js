(function() {
   function dv() {
      // CAPACITY - En-route ATFM delay - YY - CHART
      var crt_cap_ert_MM_ANSP = new google.visualization.ChartWrapper({
         chartType: 'BubbleChart',
         containerId: 'crt_cap_ert_MM_ANSP',
         dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1g_EclskD6qP8b_aYYhW3xrng616ZysYW5WVtGD9pOXk/edit?usp=sharing&alt=json&sheet=Sheet2&range=A1:E4',
         options:{
            vAxis: {
               title: 'minutes per flight',
               titleTextStyle: { color: 'grey', fontSize: 12 },
               textStyle: { color: 'grey' }
            },
            hAxis: {
                title: 'minutes per flight'
               //title: 'Source: PRU Analysis; NM',
               //titleTextStyle: { color: 'grey', fontSize: 10 }
            },
            bubble: { textStyle: {fontSize:11 }}
         },
      });
      crt_cap_ert_MM_ANSP.draw();
   }

   google.setOnLoadCallback(dv);
})();