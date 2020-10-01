({
    displayQuestions : function(component, event, screenNo, actionClicked) {
        // console.log('In DisplayQestions');
        component.set("v.body", "");
        var allQues = component.get("v.allQuestionMap");
        var options = [];
        var questionLabel;
        var questionNumberCounter=0 ;
        var QuesRespMap = component.get("v.QuesRespMap");
        var layoutStyle, responseType, responseAnswer;
        for(var i=0;i<allQues.length;i++) {
            if(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c === screenNo)
            {
                var defaultAnswer = allQues[i].defaultAnswer;
                var identifier = allQues[i].eachQuesDetails.ACN_Question_Identifier__c;
                questionLabel = (allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Show_Serial_No__c == true ? ++questionNumberCounter+'. '+allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c  : allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c);
                layoutStyle = "slds-size_1-of-"+(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Layout_Column__c != null ? allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Layout_Column__c : '1') + " divPadding";
                // Align Serial Number to rendered queston
                // layoutStyle = "slds-size_1-of-"+(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Layout_Column__c != null ? allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Layout_Column__c : '1') + " divPadding"+(allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Show_Serial_No__c == true ? ' serial-no' : '');
                
                if(actionClicked === 'NEXT')
                {
                    allQues[i].previousScreenNo = component.get("v.previousScreenNo");
                    /* if(allQues[i].allResponseDetails.length > 0) {
                        if(!QuesRespMap.includes(allQues[i].eachQuesDetails.ACN_Question_Identifier__c)){
                            QuesRespMap.push(allQues[i].eachQuesDetails.ACN_Question_Identifier__c);
                        }
                    } */
                }
                if(actionClicked === 'PREVIOUS')
                {
                    component.set("v.screenNo", screenNo);
                    // component.set("v.previousScreenNo",allQues[i].previousScreenNo);
                }
                if(allQues[i].isDefaultQuestion)
                {
                    responseType = allQues[i].eachQuesDetails.ACN_Question__r.ACN_Type__c;
                    responseAnswer = (allQues[i].allResponseDetails != '' && allQues[i].allResponseDetails != null ? allQues[i].allResponseDetails : defaultAnswer);
                    // allQues[i].defaultAnswer = '';
                    if(responseType === 'Radio'|| responseType === 'Checkbox' || responseType === 'Multi-select' || responseType === 'Picklist'){
                        options = this.optionsVal(allQues[i].eachQuesDetails.ACN_Question__r.ACN_Options__c);
                    }
                    $A.createComponent
                    (
                        "aura:html", 
                        {
                            "tag": "div",
                            "HTMLAttributes": 
                            {
                                "class" : layoutStyle
                            }
                        },
                        function(newDiv, status1, errorMessage) {
                            // console.log('In DIV ready:::: '+status1);
                            // div is ready...
                            // Text
                            if(status1 === "SUCCESS"){
                                
                                if(responseType === 'Text'){
                                    //  var a = (questionNumberCounter=='NaN' ? '' : ++questionNumberCounter +'. ');
                                    //  ++questionNumberCounter;
                                    $A.createComponent(
                                        "lightning:input", {
                                            "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c, 
                                            // "label": questionNumberCounter+allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                            "label": questionLabel,
                                            "type": "text",
                                            "required": true,
                                            "onblur": component.getReference("c.changeValue"),
                                            // "value": allQues[i].allResponseDetails
                                            "value": responseAnswer
                                        },
                                        function(newcomponent, status){
                                            // text is ready...
                                            if (newDiv.isValid() && status === "SUCCESS") {
                                                var divBody = newDiv.get("v.body");
                                                divBody.push(newcomponent);
                                                newDiv.set("v.body",divBody);
                                                
                                                var container = component.get("v.body");
                                                container.push(newDiv);
                                                component.set("v.body", container);
                                            }
                                        }
                                    );
                                }
                                // Radio
                                else if(responseType === 'Radio'){
                                    $A.createComponent(
                                        "lightning:radioGroup", {
                                            "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c,
                                            // "label": questionNumberCounter+allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                            "label": questionLabel,
                                            "options": options, 
                                            // "value": allQues[i].allResponseDetails,
                                            "value": responseAnswer,
                                            "type": "radio",
                                            "required": true,
                                            "onchange": component.getReference("c.changeValue"),
                                            "class" : allQues[i].eachQuesDetails.ACN_Options_Layout__c+" sansRegular "	// Added to Render Option in different format
                                        },
                                        function(newcomponent, status){
                                            // radio is ready...
                                            if (newDiv.isValid() && status === "SUCCESS") {
                                                var divBody = newDiv.get("v.body");
                                                divBody.push(newcomponent);
                                                newDiv.set("v.body",divBody);
                                                
                                                var container = component.get("v.body");
                                                container.push(newDiv);
                                                component.set("v.body", container);
                                            }
                                        }
                                    );
                                }
                                // Number
                                    else if(responseType === 'Number'){
                                        $A.createComponent(
                                            "lightning:input", {
                                                "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c, 
                                                //"label": allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                "label": questionLabel,
                                                "type": "number",
                                                "required": true,
                                                "onblur": component.getReference("c.changeValue"),
                                                // "value": allQues[i].allResponseDetails
                                                "value": responseAnswer
                                            },
                                            function(newcomponent, status){
                                                // number is ready...
                                                if (newDiv.isValid() && status === "SUCCESS") {
                                                    var divBody = newDiv.get("v.body");
                                                    divBody.push(newcomponent);
                                                    newDiv.set("v.body",divBody);
                                                    
                                                    var container = component.get("v.body");
                                                    container.push(newDiv);
                                                    component.set("v.body", container);
                                                }
                                            }
                                        );
                                    }
                                // Telephone
                                    else if(responseType === 'Telephone'){
                                        $A.createComponent(
                                            "lightning:input", {
                                                "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c, 
                                                //"label": allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                "label": questionLabel,
                                                "type": "tel",
                                                "required": true,
                                                "onblur": component.getReference("c.changeValue"),
                                                // "value": allQues[i].allResponseDetails
                                                "value": responseAnswer
                                            },
                                            function(newcomponent, status){
                                                // Telephone is ready...
                                                if (newDiv.isValid() && status === "SUCCESS") {
                                                    var divBody = newDiv.get("v.body");
                                                    divBody.push(newcomponent);
                                                    newDiv.set("v.body",divBody);
                                                    
                                                    var container = component.get("v.body");
                                                    container.push(newDiv);
                                                    component.set("v.body", container);
                                                }
                                            }
                                        );
                                    }
                                // Email
                                    else if(responseType === 'Email'){
                                        $A.createComponent(
                                            "lightning:input", {
                                                "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c, 
                                                //"label": allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                "label": questionLabel,
                                                "type": "email",
                                                "required": true,
                                                "onblur": component.getReference("c.changeValue"),
                                                // "value": allQues[i].allResponseDetails
                                                "value": responseAnswer
                                            },
                                            function(newcomponent, status){
                                                // Telephone is ready...
                                                if (newDiv.isValid() && status === "SUCCESS") {
                                                    var divBody = newDiv.get("v.body");
                                                    divBody.push(newcomponent);
                                                    newDiv.set("v.body",divBody);
                                                    
                                                    var container = component.get("v.body");
                                                    container.push(newDiv);
                                                    component.set("v.body", container);
                                                }
                                            }
                                        );
                                    }
                                // Percentage
                                        else if(responseType === 'Percent'){
                                            $A.createComponent(
                                                "lightning:input", {
                                                    "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c, 
                                                    //  "label": allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                    "label": questionLabel,
                                                    "type": "number",
                                                    "formatter": "percent",
                                                    "required": true,
                                                    "onblur": component.getReference("c.changeValue"),
                                                    // "value": allQues[i].allResponseDetails
                                                    "value": responseAnswer
                                                },
                                                function(newcomponent, status){
                                                    // number is ready...
                                                    if (newDiv.isValid() && status === "SUCCESS") {
                                                        var divBody = newDiv.get("v.body");
                                                        divBody.push(newcomponent);
                                                        newDiv.set("v.body",divBody);
                                                        
                                                        var container = component.get("v.body");
                                                        container.push(newDiv);
                                                        component.set("v.body", container);
                                                    }
                                                }
                                            );
                                        }
                                // checkbox        
                                            else if(responseType === 'Checkbox'){
                                                $A.createComponent(
                                                    "lightning:checkboxGroup", {
                                                        "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c,
                                                        // "label": allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                        "label": questionLabel,
                                                        "options": options,
                                                        //"value": allQues[i].allResponseDetails,
                                                        "value": responseAnswer,
                                                        "required": true,
                                                        "class" : allQues[i].eachQuesDetails.ACN_Options_Layout__c,// Added to Render Option in different format
                                                        "onchange": component.getReference("c.changeValue")
                                                    },
                                                    function(newcomponent, status){
                                                        // checkbox is ready...
                                                        if (newDiv.isValid() && status === "SUCCESS") {
                                                            var divBody = newDiv.get("v.body");
                                                            divBody.push(newcomponent);
                                                            newDiv.set("v.body",divBody);
                                                            
                                                            var container = component.get("v.body");
                                                            container.push(newDiv);
                                                            component.set("v.body", container);
                                                        }
                                                    }
                                                );
                                            }
                                // TextArea
                                                else if(responseType === 'Textarea'){
                                                    $A.createComponent(
                                                        "lightning:textarea", {
                                                            "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c,
                                                            // "label": allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                            "label": questionLabel,
                                                            "placeholder": "Type here...",
                                                            // "value": allQues[i].allResponseDetails,
                                                            "value": responseAnswer,
                                                            "required": true,
                                                            "onblur": component.getReference("c.changeValue")
                                                        },
                                                        function(newcomponent, status){
                                                            // textarea is ready...
                                                            if (newDiv.isValid() && status === "SUCCESS") {
                                                                var divBody = newDiv.get("v.body");
                                                                divBody.push(newcomponent);
                                                                newDiv.set("v.body",divBody);
                                                                
                                                                var container = component.get("v.body");
                                                                container.push(newDiv);
                                                                component.set("v.body", container);
                                                            }
                                                        }
                                                    );
                                                }
                                // Picklist Vaues
                                                    else if(responseType === 'Picklist'){
                                                        
                                                        /*  $A.createComponents(
                                        [
                                            [
                                                "lightning:select", { label: allQues[i].eachQuesDetails.ACN_Question__r.Name, name: allQues[i].eachQuesDetails.ACN_Question_Identifier__c, value : "", "onchange": component.getReference("c.changeValue")}
                                            ],
                                            [
                                                "option", { value: "Option 1", label: "Option 1" }
                                            ],
                                            
                                        ],
                                        function(components) {
                                            components[0].set("v.body", [components[1], components[2]]);
                                            component.set("v.body", components[0]);
                                        }
                                        
                                    );*/
                                                        $A.createComponent(
                                                            "c:ACN_GenericPicklist", {
                                                                "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c,
                                                                //  "label": questionNumberCounter+allQues[i].eachQuesDetails.ACN_Question__r.Name,
                                                                "label": questionLabel,
                                                                // "selectedValue": allQues[i].allResponseDetails,
                                                                "selectedValue": responseAnswer,
                                                                "options": options,
                                                                "isRequired": true
                                                            },
                                                            function(newcomponent, status){
                                                                // date is ready...
                                                                if (newDiv.isValid() && status === "SUCCESS") {
                                                                    var divBody = newDiv.get("v.body");
                                                                    divBody.push(newcomponent);
                                                                    newDiv.set("v.body",divBody);
                                                                    
                                                                    var container = component.get("v.body");
                                                                    container.push(newDiv);
                                                                    component.set("v.body", container);
                                                                }
                                                            }
                                                        );
                                                        // latest 30/09
                                                        /* $A.createComponent(
                                                            "lightning:select", 
                                                            {
                                                                "name": allQues[i].eachQuesDetails.ACN_Question_Identifier__c,
                                                                "label": allQues[i].eachQuesDetails.ACN_Question__r.Name, // ACN_Question__r.ACN_Question_Description__c
                                                                "value": allQues[i].allResponseDetails,
                                                                // "option": options,
                                                                "options": [],
                                                                "required": true,
                                                                "onchange": component.getReference("c.changeValue")
                                                            },
                                                            function(newPickListComponent, status){
                                                                if (newPickListComponent.isValid() && status === "SUCCESS") {
                                                                    for (var i = 0; i < options.length; i++){
                                                                        console.log("Options value  :: " + options[i].value + "Options label  :: " + options[i].label)
                                                                        $A.createComponent(
                                                                            "option", 
                                                                            {
                                                                                "value": options[i].value, 
                                                                                "label": options[i].label
                                                                            },
                                                                            function(newOptionComponent, status2){
                                                                                if (newOptionComponent.isValid() && status2 === "SUCCESS") {
                                                                                    console.log("options : " + newPickListComponent.get("v.options"));
                                                                                    var option = newPickListComponent.get("v.options");
                                                                                    option.push(newOptionComponent);
                                                                                    newPickListComponent.set("v.options",option);
                                                                                }
                                                                            }
                                                                        );
                                                                    }                                           
                                                                    var body = component.get("v.body");
                                                                    body.push(newPickListComponent);
                                                                    component.set("v.body", body);
                                                                }
                                                            }
                                                        ); */
                                                        
                                                        
                                                        
                                                        /* var picklistValues = options; //cmp.get("v.picklistValues");                                   
                                    $A.createComponents(                                       
                                        ["aura:html", {
                                            "tag": "select",
                                            "HTMLAttributes": {
                                                "name": allQues[i].eachQuesDetails.ACN_Question_Identifier__c,
                                                "label": allQues[i].eachQuesDetails.ACN_Question__r.Name,
                                                // "required": true,
                                               // "options": options,                                               
                                                "options" : [{ value: "Option 1", label: "Option 1" },{'label': 'No', 'value': 'n'}],
                                                // "value": allQues[i].allResponseDetails,
                                                "onchange": component.getReference("c.changeValue")
                                            }
                                        }],
                                        function(newSelect){*/
                                                        /* if (newSelect.isValid()){
                                                var offset = 0;
                                                for (var j = 0; j < picklistValues.length; j++){
                                                    var pItem = picklistValues[j];
                                                    $A.createComponent(
                                                        "ui:inputSelectOption",
                                                        {
                                                            "label":pItem.label,
                                                            "text":pItem.value
                                                        },
                                                        function(newOption) {
                                                            var option = newSelect.get("v.options");
                                                            option.push(newOption);
                                                            newSelect.set("v.options",option);
                                                        }
                                                    );
                                                }
                                            } */
                                                        /*var body = component.get("v.body");
                                            body.push(newSelect);
                                            component.set("v.body", body);
                                        }
                                    );*/
                                                    }
                                // Date   
                                                        else if(responseType === 'Date'){
                                                            $A.createComponent(
                                                                "lightning:input", {
                                                                    "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c, 
                                                                    //  "label": allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                                    "label": questionLabel,
                                                                    "type": "date",
                                                                    // "value": allQues[i].allResponseDetails,
                                                                    "value": responseAnswer,
                                                                    "required": true,
                                                                    "onchange": component.getReference("c.changeValue")
                                                                },
                                                                function(newcomponent, status){
                                                                    // date is ready...
                                                                    if (newDiv.isValid() && status === "SUCCESS") {
                                                                        var divBody = newDiv.get("v.body");
                                                                        divBody.push(newcomponent);
                                                                        newDiv.set("v.body",divBody);
                                                                        
                                                                        var container = component.get("v.body");
                                                                        container.push(newDiv);
                                                                        component.set("v.body", container);
                                                                    }
                                                                }
                                                            );
                                                        }
                                // currency
                                                            else if(responseType === 'Currency'){
                                                                $A.createComponent(
                                                                    "lightning:input", {
                                                                        "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c, 
                                                                        // "label": allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                                        "label": questionLabel,
                                                                        "type": "number",
                                                                        "formatter": "currency",
                                                                        // "value": allQues[i].allResponseDetails,
                                                                        "value": responseAnswer,
                                                                        "required": true,
                                                                        "onblur": component.getReference("c.changeValue")
                                                                    },
                                                                    function(newcomponent, status){
                                                                        // date is ready...
                                                                        if (newDiv.isValid() && status === "SUCCESS") {
                                                                            var divBody = newDiv.get("v.body");
                                                                            divBody.push(newcomponent);
                                                                            newDiv.set("v.body",divBody);
                                                                            
                                                                            var container = component.get("v.body");
                                                                            container.push(newDiv);
                                                                            component.set("v.body", container);
                                                                        }
                                                                    }
                                                                );
                                                            }
                                // Time
                                                                else if(responseType === 'Time'){
                                                                    $A.createComponent(
                                                                        "lightning:input", {
                                                                            "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c, 
                                                                            // "label": allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                                            "label": questionLabel,
                                                                            "type": "time",
                                                                            // "value": allQues[i].allResponseDetails,
                                                                            "value": responseAnswer,
                                                                            "required": true,
                                                                            "onchange": component.getReference("c.changeValue")
                                                                        },
                                                                        function(newcomponent, status){
                                                                            // time is ready...
                                                                            if (newDiv.isValid() && status === "SUCCESS") {
                                                                                var divBody = newDiv.get("v.body");
                                                                                divBody.push(newcomponent);
                                                                                newDiv.set("v.body",divBody);
                                                                                
                                                                                var container = component.get("v.body");
                                                                                container.push(newDiv);
                                                                                component.set("v.body", container);
                                                                            }
                                                                        }
                                                                    );
                                                                }
                                // DateTime       
                                                                    else if(responseType === 'Datetime'){
                                                                        $A.createComponent(
                                                                            "lightning:input", {
                                                                                "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c, 
                                                                                // "label": allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                                                "label": questionLabel,
                                                                                "type": "datetime",
                                                                                // "value": allQues[i].allResponseDetails,
                                                                                "value": responseAnswer,
                                                                                "required": true,
                                                                                "onchange": component.getReference("c.changeValue")
                                                                            },
                                                                            function(newcomponent, status){
                                                                                // datetime is ready...
                                                                                if (newDiv.isValid() && status === "SUCCESS") {
                                                                                    var divBody = newDiv.get("v.body");
                                                                                    divBody.push(newcomponent);
                                                                                    newDiv.set("v.body",divBody);
                                                                                    
                                                                                    var container = component.get("v.body");
                                                                                    container.push(newDiv);
                                                                                    component.set("v.body", container);
                                                                                }
                                                                            }
                                                                        );  
                                                                    }
                                // Output Text Displays
                                                                        else if(responseType === 'Output'){
                                                                            $A.createComponent(
                                                                                "lightning:formattedText", {
                                                                                    "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c, 
                                                                                    // "value":allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                                                    "value": questionLabel,
                                                                                    "class":"sansBold"
                                                                                },
                                                                                function(newcomponent, status){
                                                                                    // output is ready...
                                                                                    if (newDiv.isValid() && status === "SUCCESS") {
                                                                                        var divBody = newDiv.get("v.body");
                                                                                        divBody.push(newcomponent);
                                                                                        newDiv.set("v.body",divBody);
                                                                                        
                                                                                        var container = component.get("v.body");
                                                                                        container.push(newDiv);
                                                                                        component.set("v.body", container);
                                                                                    }
                                                                                }
                                                                            );       
                                                                        }
                                // Multi Picklist 
                                                                            else if(responseType === 'Multi-select'){
                                                                                $A.createComponent(
                                                                                    "lightning:dualListbox", {
                                                                                        "name": identifier, // allQues[i].eachQuesDetails.ACN_Question_Identifier__c,
                                                                                        //"label": allQues[i].eachQuesDetails.ACN_Question__r.ACN_Question_Description__c, // ACN_Question__r.Name
                                                                                        "label": questionLabel,
                                                                                        "sourceLabel": "Available",
                                                                                        "selectedLabel": "Selected", 
                                                                                        "options": options,
                                                                                        "required": true,
                                                                                        // "value": allQues[i].allResponseDetails.split(','),
                                                                                        "value": responseAnswer.split(','),
                                                                                        "onchange": component.getReference("c.changeValue")
                                                                                    },
                                                                                    function(newcomponent, status){
                                                                                        // multiselect is ready...
                                                                                        if (newDiv.isValid() && status === "SUCCESS") {
                                                                                            var divBody = newDiv.get("v.body");
                                                                                            divBody.push(newcomponent);
                                                                                            newDiv.set("v.body",divBody);
                                                                                            
                                                                                            var container = component.get("v.body");
                                                                                            container.push(newDiv);
                                                                                            component.set("v.body", container);
                                                                                        }
                                                                                    }
                                                                                );
                                                                            }
                                // Compound-Screen
                                                                                else if(responseType === 'Compound-Screen'){
                                                                                    var inputResponse = {};
                                                                                    if(allQues[i].eachQuesDetails.ACN_Input_Questions__c){
                                                                                        // console.log("screen:: " + allQues[i].eachQuesDetails.ACN_Question__r.ACN_Compound_Screen__c);                                                        
                                                                                        var inputQuesList = allQues[i].eachQuesDetails.ACN_Input_Questions__c.split(",");
                                                                                        // console.log("inputQuesList: " + inputQuesList);      
                                                                                        for(var j=0;j<inputQuesList.length;j++){
                                                                                            // console.log("inputQuesList: " + inputQuesList[j]);
                                                                                            var individualList = inputQuesList[j].trim().split("=");
                                                                                            individualList[0] = individualList[0].trim();   
                                                                                            individualList[1] = individualList[1].trim();   
                                                                                            var otherInput = false;
                                                                                            for(var k = 0;k<allQues.length;k++)
                                                                                            {                                                                
                                                                                                if(allQues[k].eachQuesDetails.ACN_Question_Identifier__c === individualList[1]){
                                                                                                    // console.log("QI **: " + individualList[1] + "response : " + allQues[k].allResponseDetails);                                                                        
                                                                                                    inputResponse[individualList[0]] = JSON.stringify(allQues[k].allResponseDetails);
                                                                                                    otherInput = true;
                                                                                                    break;
                                                                                                }                                                                   
                                                                                            }
                                                                                            if(!otherInput){
                                                                                                inputResponse[individualList[0]] = individualList[1]; 
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                    inputResponse['recordId'] = component.get("v.recordId");
                                                                                    // inputResponse['bookingId'] = 'abcd'; 
                                                                                    // console.log("inputResponse @@@@@@ : " + inputResponse);                                                        
                                                                                    $A.createComponent(
                                                                                        allQues[i].eachQuesDetails.ACN_Question__r.ACN_Compound_Screen__c, 
                                                                                        inputResponse,
                                                                                        //ipRes,
                                                                                        /* {                                                                
                                                                "recordId" : component.get("v.recordId"),
                                                            }, */
                                                                                        function(newcomponent, status) {
                                                                                            // Compound-screen is ready...
                                                                                            if (newDiv.isValid() && status === "SUCCESS") {
                                                                                                var divBody = newDiv.get("v.body");
                                                                                                divBody.push(newcomponent);
                                                                                                newDiv.set("v.body",divBody);
                                                                                                
                                                                                                var container = component.get("v.body");
                                                                                                container.push(newDiv);
                                                                                                component.set("v.body", container);
                                                                                            }
                                                                                        }
                                                                                    );
                                                                                }
                                                                                    else{  
                                                                                        // alert('Invalid Data Type');
                                                                                    }
                                
                            }
                        }
                    );
                    // call changeValue function to store the questions with default answer
                    // allQues[i].defaultAnswer = ''
                    if(defaultAnswer !== null && defaultAnswer !== '')
                    {
                        this.defaultAnswerToActualAnswer(component, identifier, defaultAnswer);
                    }
                }
            }
        }
        
    },
    optionsVal : function(options) {
        var obj = [];  
        var radioOptions = options.trim().split('\r\n');
        // console.log('radioOptions' + JSON.stringify(radioOptions).trim());
        for(var j=0;j<radioOptions.length;j++){   
            // console.log("radioOptions : " + radioOptions[j]);
            obj.push({label: radioOptions[j], value: radioOptions[j]});
        }
        // console.log('sso: ' + JSON.stringify(obj));
        return obj;
    },
    solveExpression : function(component, expression, defaultScreen, quesLogicORscreenLogic) {
        component.set("v.eachExpression", '');
        var allQues = component.get("v.allQuestionMap");
        // var component = cmp.getConcreteComponent(); // .getConcreteComponent();
        // expression=expression.replace(/ /g,'');
        // expression = "{(QI-000012 = No AND QI-000013 = Yes) =:QI-000003}";
        // {(QI-000012 = No AND QI-000013 = Yes) =:QI-000003}
        // {(QI-000012 = No AND QI-000013 = Yes) =:SN-000003}
        // {(QI-000012 != No && (QI-000015 = No AND (QI-000012 = No AND QI-000013 = No))) =:SN-000011}{(QI-000012 = Yes || QI-000013 = No) =:SN-000002}{(QI-000012 = No AND QI-000013 = Yes) =:SN-000003}        
        // console.log(expression);
        if(!expression) {
            // console.log(defaultScreen); 
            return defaultScreen;
        }
        expression=expression.replace(/\|{2}/g, ' OR ').replace(new RegExp('&&', 'g'), ' AND '); // .replace('&&', ' AND ');
        this.splitExpressionCURLY(component, expression);
        var eachExpression = component.get("v.eachExpression");
        //console.log('eachExpression ARRAY: ' + eachExpression);
        //(QI-000012 = No AND QI-000013 = No) =:SN-000011,
        //(QI-000012 = No AND QI-000013 = No) =:SN-000016,
        //(QI-000012 = No AND QI-000013 = No) =:SN-000019,
        //(QI-000012 = Yes || QI-000013 = No) =:SN-000002,
        //(QI-000012 = No AND QI-000013 = Yes) =:SN-000003        
        for(var j=0;j<eachExpression.length;j++) {
            if(eachExpression[j]) {
                var arrEachExpr = eachExpression[j].split('=:');
                arrEachExpr[0] = arrEachExpr[0].trim();
                arrEachExpr[1] = arrEachExpr[1].trim();
                if(quesLogicORscreenLogic === 'QuestionLogic') {
                    var getBooleanValue = this.comparison(component, arrEachExpr[0]);
                    if(getBooleanValue && arrEachExpr[1] === $A.get("$Label.c.ACN_Save")) {
                        this.saveQuestions(component, 'Manual');
                        break;
                    }
                    for(var z=0; z < allQues.length;z++) {
                        if(allQues[z].eachQuesDetails.ACN_Question_Identifier__c === arrEachExpr[1]){ //QI-17
                            allQues[z].isDefaultQuestion = getBooleanValue; // true
                            allQues[z].allResponseDetails = getBooleanValue ? allQues[z].allResponseDetails : '';
                            break;
                        }
                    }
                }
                else {
                    if(this.comparison(component, arrEachExpr[0])){
                        // console.log('arrEachExpr[1]::::' +arrEachExpr[1]+'::::');
                        return arrEachExpr[1];
                    }
                }
            }
        }
        return defaultScreen.trim();
    },
    splitExpressionCURLY : function(component, expression) {
        var CURLYOPEN = component.get("v.CURLYOPEN");
        var CURLYCLOSE = component.get("v.CURLYCLOSE");
        var eachExpression = component.get("v.eachExpression");
        var indexOfCurlyOpen = -1;
        var indexOfCurlyClose = -1;
        // console.log('expression:::: '+expression);
        var chars = expression.split('');
        for(var i = 0; i < chars.length; i++){
            var singleChar = chars[i];
            if(singleChar === CURLYOPEN) {
                indexOfCurlyOpen = i;
                continue;
            }
            if(singleChar === CURLYCLOSE) {
                indexOfCurlyClose = i;
                break;
            }
        }
        var replace = expression.substring(indexOfCurlyOpen + 1, indexOfCurlyClose);
        // console.log('replace:::: '+replace);
        eachExpression.push(replace); // [eachExpressionCounter++] = replace;
        component.set("v.eachExpression", eachExpression);
        expression = expression.replace( CURLYOPEN + replace + CURLYCLOSE, '');
        // console.log('expression:::: '+expression);
        if(expression !== ''){
            this.splitExpressionCURLY(component, expression);
        }
        return;
    },
    comparison : function(component, expression) {
        
        // (QI-000012 = No AND ((QI-000015 = No OR QI-000013 = Yes) AND (QI-000012 = No AND QI-000013 = No)))
        // QI-000012=No,QI-000015=No,QI-000013=Yes,QI-000012=No,QI-000013=No
        // (true AND ((false OR true) AND (true AND true))) === true
        // (QI-000012 = No AND (QI-000015 = No AND (QI-000012 = No AND QI-000013 = No)))
        // (QI-000012 = No AND (QI-000015 = No AND (QI-000013 = No)))
        // (QI-000012 = No) AND (QI-000015 = No) AND (QI-000013 = No)       
        var expr = expression;
        expr = expr.replace(/AND/g, ',').replace(/OR/g, ',').replace(/[()]/g, '');
        var eachExpression = expr.split(',');
        var eachExpressionBoolean = [];
        for(var i=0 ; i<eachExpression.length ; i++) {
            eachExpressionBoolean.push(this.getBoolenResult(component, eachExpression[i].trim()));
        }
        for(var i = 0 ; i<eachExpression.length ; i++) {
            expression = expression.replace(eachExpression[i].trim(), eachExpressionBoolean[i].toString());
        }
        //console.log('expression1111::::: '+expression);        
        //------------------------------------------------------------------------------------
        //
        // console.log('::::::::::::::::::::'+this.evaluate(component, '(false  OR  (true OR (ture AND false)))'));        
        //console.log('::::::::::::::::::::'+Boolean(this.evaluate(component, expression)));
        return this.evaluate(component, expression);
    },
    getBoolenResult : function(component, eachExpression) {
        // QI-000012=No
        // QI-000012==No
        // QI-000012!=No
        // eachExpression = eachExpression.replace(/ /g,'');
        var operators = ['==','!=','>=','<=','=','>','<']; //***the order of this Array is IMPORTANT***
        for(var i=0;i<operators.length; i++){
            if(eachExpression.includes(operators[i])){
                var arr = eachExpression.split(operators[i]);
                var qResp = this.getQuesResponse(component, arr[0]);
                var quesResponse = (qResp != null ? qResp.trim() : qResp);
                arr[1] = arr[1].trim();
                // console.log("arr[1] : " + arr[1]);
                // console.log("quesResponse : " + quesResponse );
                // alert(parseInt(quesResponse)+' :::: '+parseInt(arr[1]));
                switch (operators[i]){
                    case '=':
                    case '==':
                        eachExpression = quesResponse == arr[1];
                        break;
                    case '!=':
                        eachExpression = quesResponse != arr[1];
                        break;
                    case '>=':
                        eachExpression = parseInt(quesResponse) >= parseInt(arr[1]);
                        break;
                    case '<=':
                        eachExpression = parseInt(quesResponse) <= parseInt(arr[1]);
                        break;
                    case '>':
                        eachExpression = parseInt(quesResponse) > parseInt(arr[1]);
                        break;
                    case '<':
                        eachExpression = parseInt(quesResponse) < parseInt(arr[1]);
                        break;
                    default:
                        eachExpression =  false;
                }
                break;
            }
        }
        
        return eachExpression;
    },
    getQuesResponse : function(component, firstOperand) {
        var firstOperand = firstOperand.trim();
        var allQues = component.get("v.allQuestionMap");
        var extraParam = component.get("v.extraParam");
        var template_now = component.get("v.tempTemplateIdStr");
        for(var i=0;i<allQues.length;i++) {
            if(allQues[i].eachQuesDetails.ACN_Question_Identifier__c == firstOperand) {
                return allQues[i].allResponseDetails;
            }
        }
        // add the additional Parameter loop to find the value & return the same
        if(extraParam != null)
        {
            for(var i=0;i<extraParam.length;i++) {
                if(extraParam[i].key == firstOperand /* && extraParam[i].templateId == template_now */ ){
                    // console.log(component.get("v.tempTemplateIdStr"));
                    return extraParam[i].value;
                }
            }
        }
        return null;
    },
    evaluate : function(component, expression) {
        var OPEN = component.get("v.OPEN");
        var CLOSE = component.get("v.CLOSE");
        if(!expression.includes(OPEN)){
            return this.evaluateBooleanExpression(component, expression);
        }
        // var eachExpression = component.get("v.eachExpression");
        var indexOfOpen = -1;
        var indexOfClose = -1;
        // console.log('expression:::: '+expression);
        var chars = expression.split('');
        for(var i = 0; i < chars.length; i++){
            var singleChar = chars[i];
            if(singleChar == OPEN) {
                indexOfOpen = i;
                continue;
            }
            if(singleChar == CLOSE) {
                indexOfClose = i;
                break;
            }
        }
        var replace = expression.substring(indexOfOpen + 1, indexOfClose);
        // console.log('replace:::: '+replace);
        // eachExpression.push(replace);
        // component.set("v.eachExpression",eachExpression);
        expression = expression.replace( OPEN + replace + CLOSE, this.evaluateBooleanExpression(component, replace));
        // console.log('expression:::: '+expression);
        return this.evaluate(component, expression);
    },
    evaluateBooleanExpression :function(component, booleanExpression) {
        // true OR false OR true
        // true AND false AND true
        // booleanExpression = "false OR true"
        booleanExpression = booleanExpression.replace(/ /g,'');
        var ANDv = component.get("v.ANDv");
        var ORv = component.get("v.ORv");
        var result = false;
        /*for( var conj : booleanExpression.split(ORv)){
            
            var b = true;
            for( var single : conj.split(ANDv) ){
                b &= Boolean.valueOf(single.trim());
            }            
            result |= b;
        }
        // console.log('result: ' + result);*/
        booleanExpression.split(ORv).forEach(function myORFunction(ORitem, ORindex) {
            var b = true;
            ORitem.split(ANDv).forEach(function myANDFunction(ANDitem, ANDindex) {
                b &= Boolean(ANDitem === "true"); // (ANDitem.trim() == "true");
            });
            result |= Boolean(b);
        });
        /*booleanExpression.split(ANDv).forEach(function myFunction(item, index){
                                              console.log('result: ' + item[index]);
                                              });
        */
        // console.log('result: ' + Boolean(result));
        return Boolean(result);
    },
    saveQuestions : function(component, savePoint) {        
        var action = component.get("c.SaveQuestion");
        // console.log('allQuestionMap' + component.get("v.allQuestionMap"));
        // console.log('QuesRespMap' + component.get("v.QuesRespMap"));
        action.setParams({
            "allQuestionMap": JSON.stringify(component.get("v.allQuestionMap")),
            "QuesRespMap": component.get("v.QuesRespMap"),
            "associationTo" : component.get("v.association"),
            "recordId" : component.get("v.recordId"),
            "templateId" : component.get("v.templateId") // added by Kewal on 30/09
        });
        action.setCallback(this, function(resp1) {
            var state = resp1.getState();
            // console.log("state" + state);
            if (component.isValid() && state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Responses Saved"
                });
                toastEvent.fire();
            }
            if(savePoint == 'Manual') {
                // var actionClicked = event.getSource().getLocalId();
                var navigate = component.getEvent("navigateFlowEvent");
                navigate.setParam("action", "FINISH");
                navigate.fire();
            }
        });
        $A.enqueueAction(action);
    },
    renumberStage : function(component, event, helper) {
        // console.log('renumberStage method');
        var oldProgressPath = component.get("v.StageMap");
        for(var i=0; i<oldProgressPath.length;i++) {
            oldProgressPath[i].key = i+1;
        }
        component.set("v.StageMap",oldProgressPath);
    },
    createStageSet : function(component) {
        var tempTemplateId = component.get("v.tempTemplateId");
        var StageTemplateSet = new Set(tempTemplateId);
        var StageTemplateList = Array.from(StageTemplateSet);
        var StageTemplateSet11111 = component.get("v.StageTemplateSet");
        // StageTemplateSet.add(tempTemplateId);
        component.set("v.StageTemplateSet", StageTemplateList);        
    },
    changeValue : function(component, event, Source) {
        // var QuesRespMap = component.get("v.QuesRespMap");
        var allQues = component.get("v.allQuestionMap");
        var screenToIterate = component.get("v.screenNo");
        
        var identifier = (Source == 'AppEvent' ? event.getParam("ACN_Question_Identifier") : event.getSource().get("v.name"));
        var value = (Source == 'AppEvent' ? event.getParam("allResponseDetails") : event.getSource().get("v.value")).toString();
        
        for(var i=0; i < allQues.length;i++) {
            if(allQues[i].eachQuesDetails.ACN_Question_Identifier__c === identifier) {
                allQues[i].allResponseDetails = value;
                allQues[i].defaultAnswer = '';
                // console.log("answer value; " + value.toString());
                
                this.captureDefaultORAnsweredQID(component, identifier, value);
            }
            if(/* allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c === screenToIterate && */ allQues[i].eachQuesDetails.ACN_Question_Logic__c) {
                this.solveExpression(component, allQues[i].eachQuesDetails.ACN_Question_Logic__c, '', 'QuestionLogic');
            }
        }
        this.displayQuestions(component, event, component.get("v.screenNo"), '');
        // component.set("v.QuesRespMap", QuesRespMap);
    },
    defaultAnswerToActualAnswer : function(component, qid, answer) {
        var allQues = component.get("v.allQuestionMap");
        var screenToIterate = component.get("v.screenNo");
        
        var identifier = qid; // (Source == 'AppEvent' ? event.getParam("ACN_Question_Identifier") : Source == 'CaptureDefaultAnswers' ? qid : event.getSource().get("v.name"));
        var value = answer; // (Source == 'AppEvent' ? event.getParam("allResponseDetails") :  Source == 'CaptureDefaultAnswers' ? answer : event.getSource().get("v.value")).toString();
        
        for(var i=0; i < allQues.length;i++) {
            if(allQues[i].eachQuesDetails.ACN_Question_Identifier__c === identifier) {
                allQues[i].allResponseDetails = value;
                allQues[i].defaultAnswer = '';
                // console.log("answer value; " + value.toString());
                
                this.captureDefaultORAnsweredQID(component, identifier, value);
            }
            if(/* allQues[i].eachQuesDetails.ACN_Screen__r.ACN_Screen_Number__c === screenToIterate && */ allQues[i].eachQuesDetails.ACN_Question_Logic__c) {
                this.solveExpression(component, allQues[i].eachQuesDetails.ACN_Question_Logic__c, '', 'QuestionLogic');
            }
        }
    },
    captureDefaultORAnsweredQID : function(component, identifier, value) {
        var QuesRespMap = component.get("v.QuesRespMap");
        
        if(!QuesRespMap.includes(identifier) && value.toString() != null && value.toString() != '')
        {
            QuesRespMap.push(identifier);
        }
        else if(QuesRespMap.includes(identifier) && (value.toString() == null || value.toString() == ''))
        {
            QuesRespMap = QuesRespMap.filter(function(value, index, arr){
                return (value !== identifier);
            });
        }
        component.set("v.QuesRespMap", QuesRespMap);
    }
})