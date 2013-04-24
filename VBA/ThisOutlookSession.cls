VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisOutlookSession"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit
'
' Place this code in the "ThisOutlookSession" class module
'
' The code will:
'
' Monitor the Inbox
' Check for the existence of a specific kind of e-mail with an attachment
' Save the attachment
' Move the processed e-mail to a "processed" folder
'
'
Private WithEvents olInboxItems As Outlook.Items
Attribute olInboxItems.VB_VarHelpID = -1
Private orderNum As Integer

' Application_Startup() is a reserved function that will automatically
' be called when Outlook starts.
'
Private Sub Application_Startup()
    Dim objNS As Outlook.NameSpace
    Set objNS = Application.GetNamespace("MAPI")
    Set olInboxItems = Session.GetDefaultFolder(olFolderInbox).Items
    'Dim inboxFolder As Outlook.Folder
    'Set inboxFolder = objNS.Folders("chad.android.app@gmail.com").Folders("Inbox")
    'Set olInboxItems = inboxFolder.Items
    'Set olInboxItems = objNS.Folders("chad.android.app@gmail.com").Folders("Inbox").Items
    MsgBox "The email monitoring is active."
    orderNum = 0
End Sub
Private Sub Get_Ready()
    Dim objNS As Outlook.NameSpace
    Set objNS = Application.GetNamespace("MAPI")
    Set olInboxItems = Session.GetDefaultFolder(olFolderInbox).Items
    'Dim inboxFolder As Outlook.Folder
    'Set inboxFolder = objNS.Folders("chad.android.app@gmail.com").Folders("Inbox")
    'Set olInboxItems = inboxFolder.Items
    'Set olInboxItems = objNS.Folders("chad.android.app@gmail.com").Folders("Inbox").Items
End Sub

Sub Send_Test_Email_haha()
    Call send_test_mail("UNRATE")
    Call send_test_mail("IC4WSA")
    Call send_test_mail("PAYEMS")
End Sub
Sub check_inbox_path()
    MsgBox olInboxItems.Parent.FolderPath
    MsgBox olInboxItems.Count
End Sub

'
' This event is fired when the Inbox receives a new message
' (it can also be fired when manually moving a message from
'  another folder back to the inbox)
'
Private Sub olInboxItems_ItemAdd(ByVal Item As Object)
    Dim olDestFolder As Folder, strFolderName As String
    strFolderName = "Processed_OK"
On Error Resume Next
    Dim workingDir As String
    Dim password As String
    Dim RscriptDir As String
    password = "Carol"
    password = Chr(91) & password & Chr(93)
    workingDir = "C:\Dropbox\MSCF\Mini 4\Financial Computing III\FC III Course Project WC\workingDir\"
    RscriptDir = "C:\Program Files\R\R-2.15.1\bin\"
    
    Dim objNS As Outlook.NameSpace
    Set objNS = Application.GetNamespace("MAPI")

    Dim mailItem As Outlook.mailItem
    '
    ' Only inspect mail items
    ' Ignore appointments, meetings, tasks, etc.
    '
    If TypeOf Item Is Outlook.mailItem Then
        Set mailItem = Item
        
        '================= Checking password ===================
        Dim thisString As String
        thisString = mailItem.Subject
        ' Returns an array containing "Look", "at", and "these!".
        Dim thisStringArray() As String
        thisStringArray() = Split(thisString)
        'MsgBox thisStringArray(0)
        
        If thisStringArray(0) = password Then
            ' Subject contains the seriesID
            Dim seriesID As String
            seriesID = thisStringArray(1)
            
            ' ============ Save mail body into text file =============
            ' *** need to add referece to "Microsoft Scripting Runtime" library
            Dim FSO As New FileSystemObject
            Dim FSOFile As TextStream
            Set FSOFile = FSO.CreateTextFile(workingDir & seriesID & ".txt", True)
            FSOFile.Write (mailItem.Body)
            'MsgBox mailItem.Body
            'FSOFile.Write ("Test!")
            FSOFile.Close
            Set FSOFile = Nothing
            Set FSO = Nothing
            
            ' ==================== Run Rscript =======================
            Dim strPrgm As String, strRFile As String, strRarg As String
            strPrgm = RscriptDir & "Rscript.exe"
            strRFile = workingDir & "chad.r"
            strRFile = " " & Chr(34) & strRFile & Chr(34)
            strRarg = " " & seriesID
            Call Shell(strPrgm & strRFile & strRarg, 1)
            
            ' ================= Check report existence =======================
            
            Call check_file_existence_by_loop(workingDir, "TSA_result.txt")
            
            '============== Reply with attachments=================
            Dim MsgReply As Outlook.mailItem
            Set MsgReply = mailItem.Reply
            With MsgReply
                .Subject = "Muahahaha... Is this what you want?"
                .HTMLBody = "Please look at the attachment."
                .Body = "A series of time series analysis has been done on " & seriesID & "." & vbNewLine & _
                        "Please look at the attachment for report and plots."
                .Attachments.Add workingDir & "TSA_result.txt", olByValue, 1, ""
                .Attachments.Add workingDir & "plot1.png", olByValue, 1, "Plot 1"
                .Attachments.Add workingDir & "plot2.png", olByValue, 1, "Plot 2"
                .Attachments.Add workingDir & "plot3.png", olByValue, 1, "Plot 3"
                .Send
            End With
            Set MsgReply = Nothing
            
            
            '========== Create a folder for this order ==========
            orderNum = orderNum + 1
            Dim orderFolder As String
            orderFolder = "Order" & orderNum & "\"
            
            ' Wait for a while before moving the files
            Call wait_for_three_seconds
            
            '============= Move files into Order foler=================
            MkDir workingDir & orderFolder
            Dim FSO1 As FileSystemObject
            Set FSO1 = CreateObject("Scripting.FileSystemObject")
            FSO1.MoveFile workingDir & seriesID & ".txt", workingDir & orderFolder & seriesID & ".txt"
            FSO1.MoveFile workingDir & "TSA_result.txt", workingDir & orderFolder & "TSA_result.txt"
            FSO1.MoveFile workingDir & "plot1.png", workingDir & orderFolder & "plot1.png"
            FSO1.MoveFile workingDir & "plot2.png", workingDir & orderFolder & "plot2.png"
            FSO1.MoveFile workingDir & "plot3.png", workingDir & orderFolder & "plot3.png"

            ' ============= Error handling ===================
            If Err.Number Then
                strFolderName = "Processed_Errors"
                MsgBox "Unsuccessful because of error" & Err.Number & " " & Err.Description
            Else
                strFolderName = "Processed_OK"
            End If
            ' ---------------------------------------------------
            '============== General Error Reporting ======================
            ' Once complete, move mail item to OK/Errors folder
            ' This code assumes the folders already exist
            ' and are subfolders of the Inbox folder
           
            'Set olDestFolder = objNS.Folders("chad.android.app@gmail.com").Folders("Inbox").Folders(strFolderName)
            Set olDestFolder = Session.GetDefaultFolder(olFolderInbox).Folders(strFolderName)
            If Err.Number Then
                mailItem.Move olDestFolder
                'MsgBox Err.Description + strFolderName + vbCrLf + "Check the error folder", _
                       vbCritical, "Automated e-Mail processing unsuccessful"
            Else
                mailItem.Move olDestFolder
                'MsgBox "Message has been processed and placed in " + strFolderName, _
                        vbInformation, "Automated e-Mail processing successful"
            End If
            '------------------------------------------------------------------
            
        Else ' check sender identity
            'MsgBox "didn't pass check!"
        End If ' check sender identity
    End If 'If TypeOf Item Is Outlook.MailItem Then
    Set Item = Nothing
    Set mailItem = Nothing
End Sub
