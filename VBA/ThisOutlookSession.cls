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
    
    On Error Resume Next
    Dim workingDir As String
    Dim password As String
    password = "Carol"
    password = Chr(91) & password & Chr(93)
    workingDir = "C:\Dropbox\MSCF\Mini 4\Financial Computing III\FC III Course Project\workingDir\"
    
    Dim objNS As Outlook.NameSpace
    Set objNS = Application.GetNamespace("MAPI")

    Dim olMailItem As Outlook.MailItem
    '
    ' Only inspect mail items
    ' Ignore appointments, meetings, tasks, etc.
    '
    If TypeOf Item Is Outlook.MailItem Then
        Set olMailItem = Item
        
        
        '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ' Check if e-mail is one we want to process
        ' Test for specific subject line
        'If InStr(1, olMailItem.Sender, "carolz1207@gmail.com") > 0 Or _
        InStr(1, olMailItem.Sender, "Carol Zhang") > 0 Or _
        InStr(1, olMailItem.Sender, "Chad Android") > 0 Or _
        InStr(1, olMailItem.Sender, "Kenneth Lam") > 0 Or _
        InStr(1, olMailItem.Sender, "hkkennethlam@gmail.com") > 0 Or _
        InStr(1, olMailItem.Sender, "snagk917@gmail.com") > 0 Or _
        InStr(1, olMailItem.Sender, "Long Zheng") > 0 Then
        '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        '================= Checking password ===================
        Dim thisString As String
        thisString = olMailItem.Subject
        ' Returns an array containing "Look", "at", and "these!".
        Dim thisStringArray() As String
        thisStringArray() = Split(thisString)
        'MsgBox thisStringArray(0)
        
        If thisStringArray(0) = password Then
            
            '
            ' Once complete, move mail item to OK/Errors folder
            ' This code assumes the folders already exist
            ' and are subfolders of the Inbox folder
            '
            ' In older versions of Outlook, olDestFolder
            ' should be declared as type MAPIFolder
            ' instead of Folder
            '
            
            ' Error handling
            Dim olDestFolder As Folder, strFolderName As String
            If Err.Number Then
                strFolderName = "Processed_Errors"
            Else
                strFolderName = "Processed_OK"
            End If
            
            ' Subject contains the seriesID
            Dim seriesID As String
            seriesID = thisStringArray(1)
            
            ' ============ Save mail body into text file =============
            ' *** need to add referece to "Microsoft Scripting Runtime" library
            Dim fso As New FileSystemObject
            Dim ts As TextStream
            Set ts = fso.CreateTextFile(workingDir & seriesID & ".txt", True)
            ts.Write (olMailItem.Body)
            ts.Close
            Set ts = Nothing
            Set fso = Nothing
            
            ' ==================== Run Rscript =======================
            Dim strPrgm As String, strRFile As String, strRarg As String
            strPrgm = "C:\Program Files\R\R-2.15.1\bin\Rscript.exe"
            strRFile = workingDir & "chad.r"
            strRFile = " " & Chr(34) & strRFile & Chr(34)
            strRarg = " " & seriesID
            ' *** Use ShellAndWait!!!
            Call Shell(strPrgm & strRFile & strRarg, 1)
            
            ' ================= Check report existence =======================
            
            Call check_file_existence_by_loop(workingDir, "TSA_result.txt")
            
            '============== Reply with attachments=================
            On Error GoTo ErrorTrap
            MsgBox "Replying!"
            Dim MsgReply As Outlook.MailItem
            Set MsgReply = olMailItem.Reply
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
ErrorTrap:
            MsgBox Err.Number & " " & Err.Description & " message not sent because of error"
            
            
            '================ Display Message =====================
            'Set olDestFolder = objNS.Folders("chad.android.app@gmail.com").Folders("Inbox").Folders(strFolderName)
            Set olDestFolder = Session.GetDefaultFolder(olFolderInbox).Folders(strFolderName)
            If Err.Number Then
                olMailItem.Move olDestFolder
                'MsgBox Err.Description + strFolderName + vbCrLf + "Check the error folder", _
                       vbCritical, "Automated e-Mail processing unsuccessful"
            Else
                olMailItem.Move olDestFolder
                'MsgBox "Message has been processed and placed in " + strFolderName, _
                        vbInformation, "Automated e-Mail processing successful"
            End If
        Else ' check sender identity
            MsgBox "didn't pass check!"
        End If ' check sender identity
    End If 'If TypeOf Item Is Outlook.MailItem Then
    Set Item = Nothing
    Set olMailItem = Nothing
End Sub
