<cfset thattext='ceci est un test #application.env# a #dateFormat(now(), "dd/mm/yyyy")# à #timeFormat(now(), "HH:mm:ss")#'>

<cfoutput>    
    <cfmail
    to="jcroyer@gmail.com"
    from="site@cfdino.com"
    replyto="jcroyer@gmail.com"
    subject="CFdino.com - #thattext#"
    type="text">
    #thattext#
    </cfmail>


Test email: #thattext#

</cfoutput>