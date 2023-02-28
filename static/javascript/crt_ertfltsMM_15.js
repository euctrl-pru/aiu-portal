(function() {
   function dv(){

// TRAFFIC - ERT FLTS - MM - CHART
   var crt_ertfltsMM_15 = new google.visualization.ChartWrapper({
      chartType: 'ComboChart',
      containerId: 'crt_ertfltsMM_15',
      dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1P86i-AwsgNgBkmgj7tRFbKuEzNSApMMbRs96Y14VQX8/edit?usp=sharing&sheet=ERT_FLTS_MM&range=A4:I64&tq=where%20A%3D1&hl=en_US',
options: {     
            width: 450, height: 190, 
            chartArea: {left: 80, top: 30, width:'60%',height:'60%'},
            title: 'Avg. daily IFR flights',
            titleTextStyle : {color: 'grey', fontSize: 12},
            legend: 'none',       
            series: {
                     0: {type: 'bars', color:'#b3cccc', targetAxisIndex: 0},
                     1: {type: 'lines', color:'#B89470',lineWidth: 2, pointSize: 6, targetAxisIndex: 1}
                  },
            vAxes:{
                     0:{   title:'Avg. daily IFR flights',
                        titleTextStyle : {color: '#1F1F2E', fontSize: 11}, minValue: 0.00,
                        textStyle:{color: '#1F1F2E'}},
                     1:{   title:'cum. change vs. prev. year (%)',
                        titleTextStyle : {color: '#1F1F2E', fontSize: 11}, 
                        textStyle:{color:'#B89470'}}
                  }
            },
      view: {columns: [3,7,8], rows: [1,2,3,4,5,6,7,8,9,10,11]}
   }); crt_ertfltsMM_15.draw();  

   google.setOnLoadCallback(dv);
})();