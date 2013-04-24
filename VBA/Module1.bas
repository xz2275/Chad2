Attribute VB_Name = "Module1"
Sub tempppp()
    Dim objNS As Outlook.NameSpace
    Set objNS = Application.GetNamespace("MAPI")
    Dim inboxFolder As Outlook.Folder
    Set inboxFolder = objNS.Folders("Outlook Data Files").Folders("Inbox")
    Set olInboxItems = inboxFolder.Items
    
    

    Dim olMailItem As Outlook.MailItem
    '
    ' Only inspect mail items
    ' Ignore appointments, meetings, tasks, etc.
    '
    Dim workingDir As String
    workingDir = "C:\Dropbox\MSCF\Mini 4\Financial Computing III\FC III Course Project\workingDir\"

        Set olMailItem = olInboxItems(1)
        '
        ' Check if e-mail is one we want to process automatically
        ' Test for specific subject line
        If InStr(1, olMailItem.Sender, "carolz1207@gmail.com") > 0 Or _
        InStr(1, olMailItem.Sender, "Carol Zhang") > 0 Or _
        InStr(1, olMailItem.Sender, "Long Zheng") > 0 Then
            '
            ' Once complete, move mail item to OK/Errors folder
            ' This code assumes the folders already exist
            ' and are subfolders of the Inbox folder
            '
            ' In older versions of Outlook, olDestFolder
            ' should be declared as type MAPIFolder
            ' instead of Folder
            '
            MsgBox (olMailItem.Body)
            
            ' ========= Save mail body into text file =============
            ' *** need to add referece to "Microsoft Scripting Runtime" library
            Dim fso As New FileSystemObject
            Dim ts As TextStream
            Set ts = fso.CreateTextFile(workingDir & "Outputfile.txt", True)
            ts.Write (olMailItem.Body)
            ts.Close
            Set ts = Nothing
            Set fso = Nothing
            ' =====================================================
        End If

    Set olMailItem = Nothing
End Sub

Sub temppppp1()
    Dim workingDir As String
    workingDir = "C:\Dropbox\MSCF\Mini 4\Financial Computing III\FC III Course Project\workingDir\"
            ' ======== Run Rscript =======================
            
            strPrgm = "C:\Program Files\R\R-2.15.1\bin\Rscript.exe"
            strRFile = workingDir & "chad.r"
            strRFile = " " & Chr(34) & strRFile & Chr(34)
            
            'seriesID = "IC4WSA"
            strRarg = " " & seriesID
            
            MsgBox strRFile
            MsgBox strRarg
            Call Shell(strPrgm & strRFile & strRarg, 1)
            
            '==========================================
End Sub
Sub check_file_existence_by_loop(workingDir As String, fileName As String)
            ' ================= Delay 10 seconds =======================
            Dim currenttime As Date
            Dim starttime As Date
            Dim waitingtime As Double
            
            starttime = Now
            currenttime = Now
            Do Until currenttime + TimeValue("00:00:03") <= Now
            Loop
            
            'MsgBox "3 seconds gone."
            
            Do Until starttime + TimeValue("00:00:30") <= Now
                If Dir(workingDir & fileName) <> "" Then
                    'MsgBox "Found!"
                    Exit Do
                Else
                    'MsgBox "still monitoring."
                End If
                
                currenttime = Now
                Do Until currenttime + TimeValue("00:00:01") <= Now
                Loop
            Loop
            
            waitingtime = DateDiff("s", starttime, Now)
            
            'MsgBox "Total waiting time: " & waitingtime & " seconds."
End Sub
Sub temp321()
    Dim workingDir As String
    Dim fileName As String
    fileName = "TSA_result.txt"
    workingDir = "C:\Dropbox\MSCF\Mini 4\Financial Computing III\FC III Course Project\workingDir\"
    
    Call check_file_existence_by_loop(workingDir, fileName)
End Sub

Sub split_string_by_space()
        Dim thisString As String
        thisString = "[carol] seriesID"
        ' Returns an array containing "Look", "at", and "these!".
        Dim thisStringArray() As String
        thisStringArray() = Split(thisString)
        
        MsgBox thisStringArray(0)
        MsgBox thisStringArray(1)
End Sub

Sub temp341()
        Dim password As String
    password = "Carol"
    password = Chr(91) & password & Chr(93)
    MsgBox password
End Sub
