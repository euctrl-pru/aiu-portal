(function() {
   function dv() {
      // CAPACITY - En-route ATFM delays - TABLE
      var tbl_cap_ert_YY = new google.visualization.ChartWrapper({
         chartType: 'Table',
         containerId: 'tbl_cap_ert_YY',
         dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1g_EclskD6qP8b_aYYhW3xrng616ZysYW5WVtGD9pOXk/edit?usp=sharing&alt=json&sheet=ERT_ATFM_ANSP&range=A1:D43&headers=1',
         options: {
            //allowHtml: true,
            width: 550,
            height: 400,
         },
         view: { columns: [0, 1, 2, 3] }
      });
      tbl_cap_ert_YY.draw();
   }

   google.setOnLoadCallback(dv);
})();
