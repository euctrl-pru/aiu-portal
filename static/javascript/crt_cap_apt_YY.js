(function() {
   function dv() {
      // CAPACITY - Airport arrival ATFM delay - YY - CHART
      var crt_cap_apt_YY = new google.visualization.ChartWrapper(
         {
            chartType: 'ComboChart',
            containerId: 'crt_cap_apt_YY',
            dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1gYIeqeWdcxd7mdXImchbppdI7QvZzp7ucfZdNJbBbyE/edit?usp=sharing&alt=json&sheet=APT_ATFM_YY&range=A1:I13',
           options: {
               //width: 500, height: 300,
               //chartArea: { left: 70, top: 20 },
               chartArea: { left: 50, top: 20, width: '60%', height: '70%' },
               //title: 'Airport Arrival ATFM Delays (yearly)',
               //titleTextStyle : { color: 'grey', fontSize: 12 },
               legend: {
                  position: 'right',
                  textStyle: { color: 'grey', fontSize: 9 }
               },
               isStacked : 'true',
               series: {
                  0: { type: 'bars',  color: '#C0504D', targetAxisIndex: 0 },//AP Capacity (ATC)
                  1: { type: 'bars',  color: '#D99694', targetAxisIndex: 0 },//AP Staffing (ATC)
                  2: { type: 'bars',  color: '#E6B9B8', targetAxisIndex: 0 },//AP Disruptions (ATC)
                  3: { type: 'bars',  color: '#558ED5', targetAxisIndex: 0 },//AP Capacity (non-ATC)
                  4: { type: 'bars',  color: '#B9CDE5', targetAxisIndex: 0 },//AP Disruptions (non-ATC)
                  5: { type: 'bars',  color: '#DCE6F2', targetAxisIndex: 0 }, //AP Events (non-ATC)
                  6: { type: 'bars',  color: '#C3D69B', targetAxisIndex: 0 }//AP Weather
               },
               vAxis: {
                  title: 'minutes per arrival',
                  titleTextStyle: { color: 'grey', fontSize: 12 },
                  textStyle: { color: 'grey' }
               },
               hAxis: {
                  //title: 'Source: PRU Analysis; NM',
                  //titleTextStyle: { color: 'grey', fontSize: 10 },
                  slantedText: true,
                  showTextEvery: 1,
                  //slantedTextAngle: 40,
                  type: 'string',
                  textStyle: { fontSize: 11 }
               }
            },
            view: { columns: [0, 2, 3, 4, 6, 7, 8, 5] }
         }
      );
      crt_cap_apt_YY.draw();
   }

   google.setOnLoadCallback(dv);
})();
