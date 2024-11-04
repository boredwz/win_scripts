' Author: boredwz
' Contact: https://github.com/boredwz

Public cellYearMonth, cellWeekdays, cellTable, cellPrint, cellTrash, cellDates, cellSettingsSheet, sYear, sMonth, sWeekdays, sSettingsSheetName As String
Public rTable, rPrint, rTrash, rTrashFull, rDates, rTableCell1st, rTableCellEnd, rTableData As Range
Public iTrashItems As Integer
'
'
'
'   -------------------------------------------------------------------------------------------------------------------------
'   ----------------------------------------------------  Environment init  -------------------------------------------------
'   -------------------------------------------------------------------------------------------------------------------------
Private Sub SetVariables() ' Default values:
    cellYearMonth = "AA2" '     2024-11
    cellWeekdays = "AB2" '      1,3,5
    cellTable = "AC2" '         B5:X56
    cellPrint = "AD2" '         B3:X36
    cellTrash = "AE2" '         AA60
    cellDates = "AF2" '         D5
    cellSettingsSheet = "AG2" ' Settings
    iTrashItems = 40 '          40
End Sub
'   -------------------------------------------------------------------------------------------------------------------------
Private Function Init() ' True if arguments is valid
    'Dim zzsYearMonth, zzsWeekdays, zzsTable, zzsPrint, zzsTrash, zzsDates, zzsSettingsSheet
    SetVariables
    Init = False

    zzsYearMonth = Range(cellYearMonth).Value
    zzsWeekdays = Range(cellWeekdays).Value
    zzsTable = Range(cellTable).Value
    zzsPrint = Range(cellPrint).Value
    zzsTrash = Range(cellTrash).Value
    zzsDates = Range(cellDates).Value
    zzsSettingsSheet = Range(cellSettingsSheet).Value

    If Not IsDateValid(zzsYearMonth) Then
        MsgCellError "Year-Month", cellYearMonth, zzsYearMonth, "2024-07"
    ElseIf Not IsRangeValid(zzsTable) Then
        MsgCellError "Table range", cellTable, zzsTable, "B5:X56"
    ElseIf Not IsRangeValid(zzsPrint) Then
        MsgCellError "Print range", cellPrint, zzsPrint, "B3:X36"
    ElseIf Not IsRangeValid(zzsTrash) Then
        MsgCellError "History", cellTrash, zzsTrash, "AA60"
    ElseIf Not IsRangeValid(zzsDates) Then
        MsgCellError "Dates", cellDates, strAddressDate, "D5"
    Else
        sYear = Left(zzsYearMonth, 4)
        sMonth = Right(zzsYearMonth, 2)
        sWeekdays = Replace(zzsWeekdays, " ", "") ' remove spaces
        Set rTable = Range(zzsTable)
        Set rTableCell1st = rTable.Cells(1, 1)
        Set rTableCellEnd = rTable.Cells(rTable.Rows.Count, rTable.Columns.Count)
        If rTableCell1st.Row <> rTableCellEnd.Row Then
            Set rTableCell1st = Cells(rTableCell1st.Row + 1, rTableCell1st.Column) ' go down 1 row to include only data
        End If
        Set rTableData = Range(rTableCell1st, rTableCellEnd)
        Set rPrint = Range(zzsPrint)
        Set rTrash = Cells(Range(zzsTrash).Row, Range(zzsTrash).Column) ' A1:B2 => A1:A1
        Set rTrashFull = Range(rTrash, Cells(rTrash.Row + iTrashItems, rTableCellEnd.Column)) ' A1:A1 => A1:{end of table}{max trash items}
        Set rDates = Range(zzsDates)
        sSettingsSheetName = zzsSettingsSheet
        Init = True
    End If
End Function
'
'
'
'   -------------------------------------------------------------------------------------------------------------------------
'   ----------------------------------------------------  Subroutine (Macros)  ----------------------------------------------
'   -------------------------------------------------------------------------------------------------------------------------
Sub Filter_NoFillOnly()
    If Not Init() Then Exit Sub
    rTable.AutoFilter Field:=1, Operator:=xlFilterNoFill
End Sub
'   -------------------------------------------------------------------------------------------------------------------------
Sub Filter_Off()
    If Not Init() Then Exit Sub
    rTable.AutoFilter Field:=1
End Sub
'   -------------------------------------------------------------------------------------------------------------------------
Sub Filter_AllRefresh()
    If Not Init() Then Exit Sub
    ActiveSheet.AutoFilter.ApplyFilter
End Sub
'   -------------------------------------------------------------------------------------------------------------------------
Sub Sort_Ascending()
    If Not Init() Then Exit Sub
    rTable.Sort Key1:=rTable.Columns(1), Order1:=xlAscending, Header:=xlYes
End Sub
'   -------------------------------------------------------------------------------------------------------------------------
Sub Set_Print_area()
    If Not Init() Then Exit Sub
    ActiveSheet.PageSetup.PrintArea = rPrint.Address
End Sub
'   -------------------------------------------------------------------------------------------------------------------------
Sub Del_Row() ' Move active table row to Trash
    If Not Init() Then Exit Sub
    If Intersect(Selection, rTableData) Is Nothing Then Exit Sub ' return if not in range of table data
    
    Set zzrItemCell = Cells(ActiveCell.Row, rTableCell1st.Column) ' table 1st column (from active cell)
    Set zzrItem = Range(zzrItemCell, Cells(ActiveCell.Row, rTableCellEnd.Column)) ' table row (from active cell)

    ' Clear {zzrItem} formatting
    With zzrItem.Interior
        .Pattern = xlNone
        .TintAndShade = 0
        .PatternTintAndShade = 0
    End With
    
    ' If empty then clear contents and return
    If IsEmpty(zzrItemCell.Value) Then
        zzrItem.ClearContents
        Exit Sub
    End If

    ' Move Trash down (A1:B40) => (A2:B41)
    rTrashFull.Cut Destination:=Cells(rTrash.Row + 1, rTrash.Column)
    Call Init ' reset moved ranges

    ' Save current selection and view position
    Set zzrSavedSelection = Selection
    Set zzrSavedTopLeft = Cells(ActiveWindow.ScrollRow, ActiveWindow.ScrollColumn)

    ' Move to Trash
    zzrItem.Copy
    rTrash.PasteSpecial Paste:=xlPasteValues ' item values => Trash cell
    Application.CutCopyMode = False ' clear the clipboard
    zzrItem.ClearContents ' clear Table row contents
    
    ' Restore selection and view position
    zzrSavedSelection.Select
    With ActiveWindow
        .ScrollRow = zzrSavedTopLeft.Row
        .ScrollColumn = zzrSavedTopLeft.Column
    End With

    Sort_Ascending ' refresh
End Sub
'   -------------------------------------------------------------------------------------------------------------------------
Sub Del_Undo() ' Restore last table row from Trash
    If Not Init() Then Exit Sub
    If IsEmpty(rTrash.Value) Then Exit Sub ' return if Trash is empty

    ' resize range of Trash cell => Trash item (row)
    Set zzrTrashItem = Range(rTrash, Cells(rTrash.Row, rTableCellEnd.Column))
    Set zzrTableLastCell = Cells(rTableCellEnd.Row, rTableCell1st.Column)
    
    ' Save current selection and view position
    Set zzrSavedSelection = Selection
    Set zzrSavedTopLeft = Cells(ActiveWindow.ScrollRow, ActiveWindow.ScrollColumn)

    zzrTrashItem.Copy
    zzrTableLastCell.PasteSpecial Paste:=xlPasteValues ' item values => Table last cell
    Application.CutCopyMode = False ' clear the clipboard
    zzrTrashItem.ClearContents ' clear Trash row contents

    ' Restore selection and view position
    zzrSavedSelection.Select
    With ActiveWindow
        .ScrollRow = zzrSavedTopLeft.Row
        .ScrollColumn = zzrSavedTopLeft.Column
    End With

    ' Move Trash up (A2:B41) => (A1:B40)
    Range( _
        Cells(rTrash.Row + 1, rTrash.Column), _
        Cells(rTrash.Row + rTrashFull.Rows.Count, rTrashFull.Column) _
    ).Cut Destination:=rTrash
    Call Init ' reset moved ranges
    
    Sort_Ascending ' refresh
End Sub
'   -------------------------------------------------------------------------------------------------------------------------
Sub Dates_Fill() ' Fill table date columns
    If Not Init() Then Exit Sub
    If Not IsWeekDaysValid(sWeekdays) Then
        MsgCellError "Weekdays", cellWeekdays, sWeekdays, "1,3,5"
        Exit Sub
    End If

    If Not IsSheetExists(sSettingsSheetName) Then
        MsgBox "Settings sheet not found.", vbCritical
        Exit Sub
    End If

    dates = GetArrayOfDatesFromWeekdays(sYear, sMonth, sWeekdays)
    
    ' limit dates to 20 max
    datesCount = UBound(dates) + 1
    If datesCount > 20 Then datesCount = 20

    ' iterate starting from rDates cell and fill with dates
    'For i = LBound(dates) To (datesCount - 1)
    '    If IsDate(Cells(rDates.Row, rDates.Column + i).Value) Then
    '        Cells(rDates.Row, rDates.Column + i).Value = dates(i)
    '    End If
    'Next

    countDa = 1
    For i = rTable.Column To rTableCellEnd.Column
        Set rCell = Cells(rTable.Row, i)
        If IsDate(rCell.Value) Then ' if cell is Date
            If (countDa <= datesCount) Then
                rCell.Value = dates(countDa - 1) ' fill with Date
                countDa = countDa + 1
            Else
                rCell.Value = DateSerial(1900, 1, 0) ' when dates already filled, enter void Data into remaining columns
            End If
        End If
    Next

    Resize_TableColumns datesCount
End Sub
'   -------------------------------------------------------------------------------------------------------------------------
Private Sub Resize_TableColumns(parDatesCount) ' Resize table columns based on {Dates count}
    ' Get width values from Settings sheet
    Set zz = ThisWorkbook.Sheets(sSettingsSheetName)
    widthC1 = zz.Cells(parDatesCount + 1, 28).Value ' AA - C1
    widthC2 = zz.Cells(parDatesCount + 1, 29).Value ' AB - C2
    widthC3 = zz.Cells(parDatesCount + 1, 30).Value ' AC - C3
    widthDates = zz.Cells(parDatesCount + 1, 31).Value ' AD - date

    countC = 1
    countDa = 1
    For i = rTableCell1st.Column To rTableCellEnd.Column ' iterate table columns
        If IsDate(Cells(rTable.Row, i).Value) Then ' if cell value is Date
            If countDa > parDatesCount Then
                w = 0 ' when working dates already filled, hide remaining columns (width 0)
            Else
                w = widthDates
                countDa = countDa + 1
            End If
        ElseIf countC = 1 Then '    C1
            w = widthC1
            countC = countC + 1
        ElseIf countC = 2 Then '    C2
            w = widthC2
            countC = countC + 1
        ElseIf countC = 3 Then '    C3
            w = widthC3
            countC = countC + 1
        Else '                      default
            w = 20
        End If
        Columns(i).ColumnWidth = w ' set column width
    Next
End Sub
'   -------------------------------------------------------------------------------------------------------------------------
Sub Sheet_CreateCopy() ' Create copy of active sheet with incremented Month date
    If Not Init() Then Exit Sub

    newDate = DateSerial(sYear, sMonth + 1, 1)
    monthNumber = Month(newDate)
    If monthNumber < 10 Then monthNumber = "0" & monthNumber
    
    ActiveSheet.Copy Before:=Sheets(1)
    ActiveSheet.Name = Year(newDate) & "-" & monthNumber

    Range(cellYearMonth).Value = ActiveSheet.Name
    Dates_Fill
End Sub
'
'
'
'   -------------------------------------------------------------------------------------------------------------------------
'   ----------------------------------------------------  Functions  --------------------------------------------------------
'   -------------------------------------------------------------------------------------------------------------------------
Private Function IsRangeCellsEmpty(parStrAddress) ' True if all cells in the range are empty
    IsRangeCellsEmpty = True
    For Each cell In Range(parStrAddress)
        If Not IsEmpty(cell.Value) Then
            IsRangeCellsEmpty = False
            Exit For
        End If
    Next
End Function
'   -------------------------------------------------------------------------------------------------------------------------
Private Function IsSheetExists(parStrName) ' True if exists
    IsSheetExists = False
    For Each ws In ThisWorkbook.Sheets
        If ws.Name = parStrName Then
            IsSheetExists = True
            Exit For
        End If
    Next
End Function
'   -------------------------------------------------------------------------------------------------------------------------
Private Function IsRangeValid(parStrAddress) ' Check for A1, A1:B2, $A$1:$B$2 etc.
    On Error GoTo InvalidAddress
    Set testRange = Range(parStrAddress)
    IsRangeValid = True
    Exit Function
    
    InvalidAddress:
    IsRangeValid = False
End Function
'   -------------------------------------------------------------------------------------------------------------------------
Private Function IsDateValid(par) ' Check for YYYY-MM format
    IsDateValid = (Len(par) = 7) And (Left(par, 2) = "20") And _
        IsNumeric(Left(par, 4)) And IsNumeric(Right(par, 2))
End Function
'   -------------------------------------------------------------------------------------------------------------------------
Private Function IsWeekDaysValid(par) ' "1,2" - True; "1,0", "1,2,1", "abc", "1,2,3,4,5" - False (4 days max, not duplicates)
    IsWeekDaysValid = False
    If (par = Empty) Or IsNull(par) Or IsEmpty(par) Then Exit Function ' return if empty
    n1 = Mid(par, 1, 1)
    n2 = Mid(par, 3, 1)
    n3 = Mid(par, 5, 1)
    n4 = Mid(par, 7, 1)
    nums = n1 & n2 & n3 & n4
    delims = Mid(par, 2, 1) & Mid(par, 4, 1) & Mid(par, 6, 1)

    ' True if duplicates found (112 (1) / 2452 (2) / ..)
    duplFound = False
    For i = 1 To Len(nums)
        If InStr(i + 1, nums, Mid(nums, i, 1)) > 0 Then
            duplFound = True
            Exit For
        End If
    Next
    
    ' False if /^,{0,3}$/
    If (delims = Empty) Or IsNull(delims) Or IsEmpty(delims) Then
        delimsInvalid = False
    Else
        delimsInvalid = Not ((delims = ",") Or (delims = ",,") Or (delims = ",,,"))
    End If

    ' Return: not numeric / invalid delims / duplicates found
    If (Not IsNumeric(nums)) Or delimsInvalid Or duplFound Then Exit Function

    ' Check if days = [1-7]
    If (Len(par) = 1) Then IsWeekDaysValid = (n1 >= 1) And (n1 <= 7)
    If (Len(par) = 3) Then IsWeekDaysValid = (n1 >= 1) And (n1 <= 7) And (n2 >= 1) And (n2 <= 7)
    If (Len(par) = 5) Then IsWeekDaysValid = (n1 >= 1) And (n1 <= 7) And (n2 >= 1) And (n2 <= 7) And (n3 >= 1) And (n3 <= 7)
    If (Len(par) = 7) Then IsWeekDaysValid = (n1 >= 1) And (n1 <= 7) And (n2 >= 1) And (n2 <= 7) And (n3 >= 1) And (n3 <= 7) And (n4 >= 1) And (n4 <= 7)
End Function
'   -------------------------------------------------------------------------------------------------------------------------
Private Function GetArrayFromRangeString(par) ' AA=>[AA],[],[AA],[] / A1=>[A],[1],[A],[1] / $A$1:B2=>[A],[1],[B],[2]
    par = Split(Replace(par, "$", ""), ":") ' split A1:B2 => A1 and B2 / A1 => A1
    ReDim Preserve par(1)
    If IsEmpty(par(1)) Then par(1) = par(0) ' make A1:A1 from A1
    For Each cell In par
        For i = 1 To Len(cell)
            If IsNumeric(Mid(cell, i)) Then
                ab = Mid(cell, 1, i - 1) ' AA
                xy = Mid(cell, i) ' 11
                Exit For
            End If
        Next
        If IsEmpty(ab) Then ab = cell ' AA
        strArr = strArr & "," & ab & "," & xy ' ,AA,*
    Next
    GetRangeArray = Split(Mid(strArr, 2), ",") ' ,AA,*,AA,* => Array(AA,*,AA,*)
End Function
'   -------------------------------------------------------------------------------------------------------------------------
Private Function GetArrayOfDatesFromWeekdays(parYear, parMonth, parWeekdays) ' returns array of dates
    parWeekdaysNums = Replace(parWeekDays, ",", "") ' join (1,2,3,4 => 1234)
    monthDaysCount = Day(DateSerial(CInt(parYear), CInt(parMonth) + 1, 1) - 1) ' days in a month = 1st day of the next month - 1 day
    For i = 1 To monthDaysCount
        iDate = DateSerial(CInt(parYear), CInt(parMonth), i)
        If InStr(parWeekDaysNums, Weekday(iDate, vbMonday)) > 0 Then
            dates = dates & "," & parYear & "/" & parMonth & "/" & i ' concat date (when weekday matches)
        End If
    Next
    GetArrayOfDatesFromWeekdays = Split(Mid(dates, 2), ",") ' remove first "," symbol and return as array
End Function
'   -------------------------------------------------------------------------------------------------------------------------
Private Sub MsgCellError(parName, parCell, parValue, parValueDefault)
    MsgBox _
        parName & " (" & parCell & "):" & vbNewLine & parValue & _
        vbNewLine & vbNewLine & "Try like this:" & vbNewLine & parValueDefault, _
        vbCritical, parName & " cell value is invalid!"
End Sub
'
'
'
'   -------------------------------------------------------------------------------------------------------------------------
'   ----------------------------------------------------  Other  ------------------------------------------------------------
'   -------------------------------------------------------------------------------------------------------------------------
Private Sub YOGA_Refresh_dates_from_D3() ' another approach
    cellDate = Range("D3").Value
    isMonday = (Weekday(cellDate) = vbMonday)
    isWednesday = (Weekday(cellDate) = vbWednesday)
    
    ' Display the result
    If isMonday Then
        Range("E3").Formula = "=D3 + 2"
        Range("F3").Formula = "=E3 + 2"
        Range("G3").Formula = "=F3 + 3"
    ElseIf isWednesday Then
        Range("E3").Formula = "=D3 + 2"
        Range("F3").Formula = "=E3 + 3"
        Range("G3").Formula = "=F3 + 2"
    Else
        Range("E3").Formula = "=D3 + 3"
        Range("F3").Formula = "=E3 + 2"
        Range("G3").Formula = "=F3 + 2"
    End If
    
    'Range("E3:G3").Select
    'Selection.AutoFill Destination:=Range("E3:P3"), Type:=xlFillDefault
    Range("E3:G3").AutoFill Destination:=Range("E3:P3"), Type:=xlFillDefault
End Sub