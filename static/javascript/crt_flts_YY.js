(function() {
   function dv() {
      // CAPACITY - En-route ATFM delay - YY - CHART
      var crt_flts_YY = new google.visualization.ChartWrapper(
         {
            chartType: 'ComboChart',
            containerId: 'crt_flts_YY',
            dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1Ap6_pXhVLZcgfUcdbqsUBvZaI_AdVsT35XLY1oPKyJ4/edit?usp=sharing&sheet=ERT_FLTS_YY&range=A1:D13&headers=1&hl=en_GB',
            options: {
               //width: 500, 
               height: 250,
               //chartArea: { left: 75, top: 20 },
               //title: 'Average Daily Flights (yearly)',
               //titleTextStyle: { color: 'grey', fontSize: 12 },
               chartArea: { left: 50, top: 20, width: '70%', height: '70%' },
               legend: {
                  position: 'top',
                  maxLines: 2,
                  textStyle: { color: 'grey', fontSize: 10 }
               },
               series: {
                  0: {
                     type: 'lines',
                     color: '#B9CDE5',
                     lineWidth: 2,
                     pointSize: 7,
                     targetAxisIndex: 0
                  },
                  1: {
                     type: 'lines',
                     color: '#376092',
                     lineWidth: 2,
                     pointSize: 7,
                     targetAxisIndex: 1
                  }
               },
               vAxes:{
                  0: {
                     title: 'Average Daily Flights',
                     titleTextStyle: { color: 'grey', fontSize: 11 },
                     minValue: 20000,
                     viewWindow: { min: 20000 },
                     format: 'short'
                  },
                  1: {
                     title: 'year on year (%)',
                     titleTextStyle: { color: '#376092', fontSize: 11 },
                     textStyle: { color: '#376092' }
                  }
               },
               hAxis: {
                  //title: 'Source: PRU Analysis; NM',
                  //titleTextStyle: { color: 'grey', fontSize: 10 },
                  //slantedText: true,
                  showTextEvery: 1,
                  //slantedTextAngle: 40
               }
            },
            view: { columns: [0, 2, 3] }
         }
      );
      crt_flts_YY.draw();
   }

   google.setOnLoadCallback(dv);

})();
