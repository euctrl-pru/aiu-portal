(function() {
   function dv() {
      // ENVIRONMENT - Horizontal flight efficiency - TABLE
      var tbl_hfe_YY = new google.visualization.ChartWrapper({
         chartType: 'Table',
         containerId: 'tbl_hfe_YY',
         dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1KgOIBF93axvXD6ENQYvEsWHqnA8eW_RvGV4EQlGava4/edit?usp=sharing&sheet=HFE_ENTITY&range=A1:D53&headers=1',
         options: {
            //allowHtml: true,
           // width: 550,
            height: 450,
         },
         view: { columns: [0, 1, 2, 3] }
      });
      tbl_hfe_YY.draw();
   }

   google.setOnLoadCallback(dv);
})();