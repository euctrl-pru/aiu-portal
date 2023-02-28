(function() {
   function dv(){
      // TRAFFIC - Controlled flights - TABLE
      var tbl_flts_YY = new google.visualization.ChartWrapper({
         chartType: 'Table',
         containerId: 'tbl_flts_YY',
         dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1Ap6_pXhVLZcgfUcdbqsUBvZaI_AdVsT35XLY1oPKyJ4/edit?usp=sharing&alt=json&sheet=ERT_FLTS_ANSP&range=A1:D43&headers=1',
         options: {
            //allowHtml: true,
            width: 550,
            height: 200,
         },
         view: { columns: [0, 1, 2, 3] }
      });
      tbl_flts_YY.draw();
   }

   google.setOnLoadCallback(dv);
})();