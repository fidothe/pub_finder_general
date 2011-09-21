/* Pub Finder General */

$(document).ready(function(){
    var datetest = document.createElement("input");
    datetest.setAttribute("type", "date");
    if (datetest.type == "text") {
        $("#review_date").datepicker({ dateFormat: "yy-mm-dd" });
    }
});
