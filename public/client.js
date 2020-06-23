/*global $ io _*/

/* Code: */

var defaultMatrixWidth = 3;
var defaultMatrixHeight = 3;

var lastSendTime;

function respondToMatrixError (error) {
  $("#myErrorAlert").fadeTo(200, 1);
  $('html, body').animate({
    scrollTop: $("#myErrorAlert").offset().top
  }, 1000);
};


function respondToMatrixData (data) {
  if (new Date() - lastSendTime > (.4 * 1000)) {
    $('#computeSpinner').removeClass('spin');
  } else {
    setTimeout(function() {
      $('#computeSpinner').removeClass('spin');
    }, 400);;
  }

  $('html, body').animate({
    scrollTop: $("#outputStart").offset().top
  }, 1000);

  $("#matrixInfo").empty();
  $("#detValue").val((data.det !== null) ? data.det : "Not possible");
  fillMatrixTable("#rrefMatrix", data.rref);
  if (data.linInd.isLinearlyIndependent) {
    addMatrixInfoLine("The column vectors of this matrix are linearly independent! ", true);
  } else {
    addMatrixInfoLine("The column vectors of this matrix are not linearly independent. "
        + data.linInd.reason, false);
  }
  if (data.inverse) {
    addMatrixInfoLine("This matrix is invertible because it " +
                      "reduces to the identity matrix.", true);

    fillMatrixTable("#inverseMatrix", data.inverse);
  } else {
    addMatrixInfoLine("This matrix is not invertible because " +
                      "it cannot be reduced to an identity matrix.", false);
    spoofFillMatrix("#inverseMatrix", data.size.height, data.size.width);
  }

    var solutionsText = "The system of equations defined by the rows has " + {
        "1": "a unique solution.",
        "0": "no solution.",
        "-1": "infinitely many solutions.",
    }[data.solutions.value];

  addMatrixInfoLine(solutionsText, (data.solutions.value !== 0));

    var consistentText = "This matrix defines a" +
	((data.solutions.value !== 0) ? " consistent" : "n inconsistent") +
	" system of equations.";
  addMatrixInfoLine(consistentText, (data.solutions.value !== 0));
};



/**
 * Fill table with matrix
 */
function fillMatrixTable(table, matrix) {
    $(table).empty();
    $.each(matrix.data, function(i, row) {
        var tRow = $('<tr>', {
            class: 'matrixRow'
        });
        $.each(row, function(j, value) {

            tRow.append($('<td>', {
                text: (parseFloat(value)) ? (Math.round(parseFloat(value*1000)) / 1000) : value,
                class: 'matrixData'
            }));

        });
        $(table).append(tRow);
    });
}

/**
 * Fill output with empty data
 */
function spoofFillMatrix(table, n, m) {
    fillMatrixTable(table, {
        data: (function() {
            var result = new Array(n);
            for (var i = 0; i < n; i++) {
                var row = new Array(m);
                for (var j = 0; j < m; j++) {
                    row[j] = "  ";
                }
                result[i] = row;
            }
            return result;
        })()
    });
}

/**
 * Resize matrix input
 */
function resizeMatrixInputTable(height, width) {
    var oldData = getInputData(true);
    $("#inputMatrix").empty();
    for (var i = 0; i < height; i++) {
        var tRow = $('<tr>', { class: 'matrixRow' });
        for (var j = 0; j < width; j++) {

            tRow.append($('<td>', {
                class: 'matrixData',
                html: $("<input>", {
                    class: "matrixInput form-control",
                    type: "number"
                })
            }));
        }
        $("#inputMatrix").append(tRow);
    }
    spoofFillMatrix("#rrefMatrix", height, width);
    spoofFillMatrix("#inverseMatrix", height, width);
    fillInputMatrix(oldData);
}

/**
 * Try resizing input matrix
 */
function tryResizeInput() {
    var n = parseInt($("#matrixHeightInput").val());
    var m = parseInt($("#matrixWidthInput").val());
    if ((!isNaN(n)) &&
        (!isNaN(m)) &&
        m > 0 &&
        n > 0) {
        resizeMatrixInputTable(n, m);
    } else {
        console.log("error resizing");
    }
}

function fillInputMatrix(data) {
    $("#inputMatrix tr").each(function(i) {
        var thisRow = [];
        var tableData = $(this).find('td input');
        if (tableData.length > 0) {
            tableData.each(function(j, elm) {
                elm.value = ( data  ? (data[i] ? data[i][j] : null) : null);
            });
        }
    });
}

function addMatrixInfoLine(message, good) {
    var info = $("#matrixInfo");

    var item = $("<li>", {
        class: "alert-box " + (good ? "success" : "warning")
    });

    var innerlist = $("<ul>", {
        class: "inline-list"
    });

    innerlist.append($("<li>", {
        class: "glyphicon "  + ((good) ? "glyphicon-ok" : "glyphicon-asterisk")
    }));

    innerlist.append($("<li>", {
        text: message
    }));
    item.append(innerlist);

    info.append(item);
}

/**
 * Get input matrix
 */
function getInputData(ignoreErrors) {
    var data = [];
    var error = false;
    $("#inputMatrix tr").each(function() {
        if (error && !ignoreErrors) return false;
        var thisRow = [];
        var tableData = $(this).find('td input');
        if (tableData.length > 0) {
            tableData.each(function() {
                var val = parseFloat($(this).val());
                if (isNaN(val)) {
                    error = true;
                } else {
                    thisRow.push(val);
                }
            });
            data.push(thisRow);
        }
    });
    if (error && !ignoreErrors) return null;
    return data;
}


/**
 * Get input and send if OK
 */
function trySendMatrix() {
    var data = getInputData();
    var error = data === null;

    if (!error) {
        $('#computeSpinner').addClass('spin');
        lastSendTime = new Date();
        $
            .ajax(window.MMP.urls.Matrix.compute, {
                data : JSON.stringify(data),
                contentType : 'application/json',
                type : 'POST',
            })
            .then((response, a, b) => {
                respondToMatrixData(response);
            })
            .fail((error) => {
                respondToMatrixError(error);
            })

    } else {
        $("#myAlert").fadeTo(200, 1);
    }
}

$(document).ready(function() {
    $('#myAlert').hide();
    $('#myErrorAlert').hide();
    resizeMatrixInputTable(defaultMatrixHeight, defaultMatrixWidth);
    $("#sizeForm").submit(function() {
        tryResizeInput();
        return false;
    });
    $("#matrixWidthInput, #matrixHeightInput").change(function(e) {
        if (e.target.value > 8) {
            $(this).val(3);
            return false;
        }
        tryResizeInput();
    });

    $("#inputMatrixForm").submit(function() {
        trySendMatrix();
        return false;
    });
    $('#myErrorAlert').hide();
});



