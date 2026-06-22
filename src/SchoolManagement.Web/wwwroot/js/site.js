// Initialize DataTables on elements with the 'table-datatable' class.
// This single general method handles search, pagination, and Excel/PDF exports.
$(document).ready(function() {
    // Smooth Page transitions on sidebar links click (fade-out before navigation)
    $('.menu-link').on('click', function(e) {
        var link = $(this);
        var href = link.attr('href');
        
        if (href && href !== '#' && !link.attr('target') && !href.startsWith('javascript:')) {
            e.preventDefault();
            $('.main-content').addClass('fade-out');
            setTimeout(function() {
                window.location.href = href;
            }, 250); // Matches the CSS fadeOut animation duration
        }
    });

    $('.table-datatable').each(function() {
        var table = $(this);
        var columnCount = table.find('thead th').length;
        var targets = [];
        if (columnCount > 0) {
            targets.push(columnCount - 1); // Exclude last column (Actions) from ordering
        }
        var hasPhoto = table.find('thead th').first().text().trim().toLowerCase() === 'photo';
        if (hasPhoto) {
            targets.push(0); // Exclude first column (Photo) from ordering
        }

        table.DataTable({
            "paging": true,
            "ordering": true,
            "info": true,
            "searching": true,
            "pageLength": 10,
            "lengthMenu": [5, 10, 25, 50, 100],
            "dom": "<'row mb-3 align-items-center'<'col-sm-6'l><'col-sm-6 text-end'B>>" +
                   "<'row'<'col-sm-12'tr>>" +
                   "<'row mt-3 align-items-center'<'col-sm-5'i><'col-sm-7'p>>",
            "columnDefs": [
                { "orderable": false, "targets": targets }
            ],
            "buttons": [
                {
                    extend: 'excelHtml5',
                    text: '<i class="bi bi-file-earmark-excel-fill me-1"></i> Excel',
                    className: 'btn btn-success btn-sm me-2 shadow-sm',
                    exportOptions: {
                        columns: ':not(:last-child)' // Exclude actions column
                    }
                },
                {
                    extend: 'pdfHtml5',
                    text: '<i class="bi bi-file-earmark-pdf-fill me-1"></i> PDF',
                    className: 'btn btn-danger btn-sm shadow-sm',
                    exportOptions: {
                        columns: ':not(:last-child)' // Exclude actions column
                    }
                }
            ],
            "language": {
                "search": "",
                "searchPlaceholder": "Search records..."
            }
        });
    });
});
