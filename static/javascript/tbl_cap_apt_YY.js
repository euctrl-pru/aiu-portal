(function() {
   function dv() {
      // CAPACITY - Airport Arrival ATFM delays - TABLE
      var tbl_cap_apt_YY = new google.visualization.ChartWrapper({
         chartType: 'Table',
         containerId: 'tbl_cap_apt_YY',
         dataSourceUrl: 'https://docs.google.com/spreadsheets/d/1gYIeqeWdcxd7mdXImchbppdI7QvZzp7ucfZdNJbBbyE/edit?usp=sharing&alt=json&sheet=APT_ATFM_STATE&range=A1:E227&headers=1',
         options: {
            //allowHtml: true,
            width: 550,
            height: 420,
            sort: 'enable',
            sortColumn: 2,
            sortAscending: false
         },
         view: { columns: [0, 1, 2, 3, 4] }
      });
      tbl_cap_apt_YY.draw();
   }

   google.setOnLoadCallback(dv);
})();