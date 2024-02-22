import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application


var behavior = function() {
var dropdown = document.getElementById('dropdown');
    var cipher_dropdown = document.getElementById('dropdown_cipher')

    var block_size = document.getElementById('block_size')

    var hiddenElement1 = document.getElementById('hidden-element1');
    var hiddenElement2 = document.getElementById('hidden-element2');
    var hiddenElement3 = document.getElementById('hidden-element3');
    var hiddenElement4 = document.getElementById('hidden-element4');
    var hiddenElement5 = document.getElementById('hidden-element5');
    var hiddenElement6 = document.getElementById('hidden-element6');

    const createTable = (size) => {
        
    }

    block_size.addEventListener('change', function(e) {
        var size = parseInt(e.target.value)
        var tableHTML = '<table>';
        var numRows = size
        var numCols = size
        // Loop to generate table rows and cells
        var count = 0
        for (var i = 0; i < numRows; i++) {
            tableHTML += '<tr>';
            for (var j = 0; j < numCols; j++) {
                tableHTML += `<td><input type="number" name="${count}" id="${count}"></td>`;
                count++;
            }
            tableHTML += '</tr>';
        }
        
        tableHTML += '</table>';
        
        // Remove the previous table, if exists
        var tableContainer = document.getElementById('key_grid');

        while (tableContainer.firstChild) {
            if (tableContainer.firstChild) tableContainer.removeChild(tableContainer.firstChild);
        }

        // Insert the new table HTML into the container element
        tableContainer.innerHTML = tableHTML;
    })


    cipher_dropdown.addEventListener('change', function() {
        if (cipher_dropdown.value == 'affine_cipher') {
            hiddenElement5.style.display = 'block'
            hiddenElement4.style.display = 'none'
            hiddenElement6.style.display = 'none'
        } else if (cipher_dropdown.value == 'hill_cipher') {
            hiddenElement6.style.display = 'block'
            hiddenElement4.style.display = 'none'
            hiddenElement5.style.display = 'none'
        }else {
            hiddenElement4.style.display = 'block'
            hiddenElement5.style.display = 'none'
            hiddenElement6.style.display = 'none'
        }
    })

    dropdown.addEventListener('change', function() {
        if (dropdown.value === 'text') {
            hiddenElement1.style.display = 'block';
            hiddenElement2.style.display = 'none';
            hiddenElement3.style.display = 'none';
        } else if (dropdown.value === 'textfile'){
            hiddenElement2.style.display = 'block'
            hiddenElement1.style.display = 'none';
            hiddenElement3.style.display = 'none';
        } else {
            hiddenElement3.style.display = 'block';
            hiddenElement1.style.display = 'none';
            hiddenElement2.style.display = 'none';
        }
    });


    var downloadLinks = document.querySelectorAll('.download-link');
    
    // Attach click event listener to each download link
    // downloadLinks.forEach(function(link) {
    //   link.addEventListener('click', function(event) {
    //     // Prevent default link behavior (i.e., opening the link)
    //     event.preventDefault();
    //     // console.log("this is link: ", link)
    //     // console.log("this is link: ", link.getAttribute('class'))
    //     // console.log("this is link: ", link.getAttribute('data-data_url'))
    //     // console.log("this is link: ", link.getAttribute('href'))
        
    //     // Get data URL and filename from the data attributes
    //     var dataUrl = link.getAttribute('data-data-url');
    //     var filename = link.getAttribute('data-filename');
        
    //     console.log("this is data url", dataUrl)
    //     // Create an anchor element to trigger the download
    //     var anchor = document.createElement('a');
    //     anchor.href = dataUrl;
    //     anchor.download = filename;
    //     anchor.click(); // Trigger the download
        
    //     // Clean up the anchor element
    //     anchor.remove();
    //   });
    // });
}
document.addEventListener('DOMContentLoaded', function() {
    behavior();
});

document.addEventListener("turbo:load", (event) => {
    console.log("turbo:load. runs every time a page is loaded");
    behavior();
  });


export { application }
