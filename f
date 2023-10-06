hi
valid_riskcode_meta = ['EN', 'SA', '4T', 'KS', '3T', 'D5', 'SL', 'NB', 'PG', 'XC', 'Q', 'FA', 'XR', 'CF', 'XY',
                               'E2', 'P7', 'E5', 'P', 'CY', 'X1', 'NX', 'MP', 'GH', 'XQ', 'BD', 'TS', 'UA', 'D3', 'E8',
                               'F2', 'CT', 'MF', 'KT', 'KP', 'UR', '6T', 'E3', '3E', 'AP', 'FM', 'NP', 'B2', 'E4', 'GN',
                               'WX', 'GM', 'X2', 'XU', 'N', 'TL', 'EM', 'KX', 'PQ', 'D2', 'WA', 'SB', 'KB', 'D7',
                               'NULL', 'MI', 'PB', 'XA', 'JB', 'PZ', '1T', 'LE', 'VX', '2E', 'PF', 'CZ', 'MG', 'EH',
                               '1E', 'W', 'G', '2T', 'TU', 'US', 'UC', 'H2', 'M4', 'SR', 'NL', 'F4', 'F5', 'TO', 'V',
                               'RX', 'XM', 'XG', 'PC', 'GT', 'WB', 'KA', 'P5', 'GC', 'D4', 'L2', 'HP', 'X3', 'BB', 'PN',
                               'W6', 'M2', 'ML', 'B5', 'P2', 'W3', 'KAKC', 'EF', 'EG', 'XE', 'D9', 'CB', '8T', '5T',
                               'TC', 'M3', 'EY', 'NS', 'NA', 'E6', 'PR', 'AW', 'TR', 'TT', 'W4', 'T', '4E', 'TW', 'H3',
                               'AG', '7T', 'E9', 'KG', 'AO', 'EZ', 'SO', 'EP', 'PL', 'M5', 'XN', 'CR', 'W5', 'DC', 'EB',
                               'NR', 'TX', 'LJ', 'B3', 'FG', 'B', 'XT', 'M6', 'XJ', 'P3', 'L3', 'KM', 'WL', 'XH', 'TE',
                               'NC', 'PU', 'GS', 'EC', 'D6', 'EA', 'XF', 'E7', 'O', 'SC', 'HA', 'CC', 'MH', 'P4', 'VL',
                               'B4', 'GX', 'F3', 'NV', 'P6', 'D8']

def clean_percentage_int_risk(line):
    try:
        import string
        import re
        remove = string.punctuation
        remove = remove.replace(".", "")
        remove = remove.replace("", "")
        pattern = r"[{}]".format(re.escape(remove))
        line = re.sub(pattern, "", line)
        if float(line) <= 100 and float(line) >= 0:
            writ_line = '{:3.5f}'.format(float(line))
            return (line)
        else:
            return ''
    except Exception as e:
        return ''
    
def get_coordinates2(df_line, page_no, start_on_page, end_on_page):
    
    if (start_on_page < len(' '.join(df_line.loc[df_line['page']==page_no,'line_text'].tolist()))) and (end_on_page <= len(' '.join(df_line.loc[df_line['page']==page_no,'line_text'].tolist()))):
    
        line_no_ls = df_line.loc[df_line['page']==page_no].index.tolist()
        line_no_ls.sort()
        text=''
        start_line=None
        end_line=line_no_ls[0]
        for line_no in line_no_ls:
            text = text+df_line.loc[line_no,'line_text']+' '
            text_len = len(text)-1
            if text_len>start_on_page and start_line==None:
                start_line=line_no
            if text_len>=end_on_page:
                end_line=line_no
                break

        x_mins=[]
        x_maxs=[]
        y_mins=[]
        y_maxs=[]
        lines=[]
        for idx in range(start_line,end_line+1):
            lines.append(idx)
            x_mins.append(df_line.loc[idx,'xmin'])
            y_mins.append(df_line.loc[idx,'ymin'])
            x_maxs.append(df_line.loc[idx,'xmax'])
            y_maxs.append(df_line.loc[idx,'ymax'])
            
        # merging all lines
        output={}
        output['lines']=lines
        output['xmin']=min(x_mins)
        output['ymin']=min(y_mins)
        output['xmax']=max(x_maxs)
        output['ymax']=max(y_maxs)
        
        return output
    else:
        raise Exception("start_on_page or end_on_page given is greater than page length")
    
def riskCodeAndPercentageExtractor(text,riskCodeList,tok):
    if text:
        print("text",text)
        token = tok.lower()
        x= re.findall(r'[\d\.\d\%]*%+',text)
        riskCodeData = []
        riskCode = []
        riskPercentage = []
        if x:
            ind = text.lower().find(token)
            newText = text[ind+len(token)+1:]
            for i in x:
                found_value_flag = False
#                 print('current newtext',newText)
                value = riskCodeAndPerc(newText,i,riskCodeList)
#                 print('value to append',value)
                if value:
                    riskCode.append(value[0])
                    riskPercentage.append(value[1])
#                     print('After appending',riskCode,riskPercentage)
                    found_value_flag = True
                    temp_ind_code = newText.lower().find(value[0].lower())
                    temp_ind_value = newText.lower().find(value[1].lower())
                    temp_ind_list = [temp_ind_code,temp_ind_value]
                    max_amount = max(temp_ind_list[0],temp_ind_list[1])
                    max_ind = temp_ind_list.index(max_amount)
                    if max_ind == 0:
                        slice_ind = max_amount + len(value[0])
                    else:
                        slice_ind = max_amount + len(value[1])
                if found_value_flag:
                    newText = newText[slice_ind:]
                else:
                    temp_ind = newText.find(i)
                    newText = newText[temp_ind+len(i):]
            print('219====',riskCode,riskPercentage)
            return [riskCode,riskPercentage]
        else:
            text = re.sub('[^A-Za-z0-9%.]+', ' ', text)
            ind = text.lower().find(token)
            newText = text[ind+len(token):]
            newText = newText.split()
            for i in newText:
                if i in riskCodeList:
                    riskCodeData.append(i)
            return [riskCodeData,None]
    
def riskCodeAndPerc(text,riskPer,riskCodeList): 
    output = []
    text = re.sub('[^A-Za-z0-9%.]+', ' ', text)
    text = text.replace("at" ,"")
#     print(text,'99999')
    textSplit = text.split()
    

    if riskPer in textSplit:
        value= textSplit.index(str(riskPer))
    else:
        found = False
        for i in textSplit:
            if riskPer in i:
                value = textSplit.index(str(i))
                found = True
                break
        if not found:
            return None
        
#     if value +1 < len(textSplit) and textSplit[value + 1] in vriskCodeList:
#         return [textSplit[value +1],riskPer]
    ## Searching Risk Code towards 1st left and then 1st right and so on 
    leftInd  = 0 
    rightInd = 0
    for i in range(1,len(textSplit)):
        leftInd = value - i
        rightInd = value + i
            
            
         ## Searching Risk Code in Left Side first
        if leftInd >= 0:
            riskCode = riskCodeSearch(textSplit[leftInd],riskCodeList)
            if riskCode:
                output.append(riskCode)
                output.append(riskPer)
                return output
            
        if rightInd <len(textSplit):
            riskCode = riskCodeSearch(textSplit[rightInd],riskCodeList)
            if riskCode:
                output.append(riskCode)
                output.append(riskPer)
                return output
    return None

def riskCodeSearch(text,riskCodeList):
    if (text) and text.isupper():
        text = re.sub('[^A-Z0-9/]+', '', text)
        if (len(text) < 4):
            for i in riskCodeList:
                if i == text:
                    return text
            return None
try:
            b = [{'Risk Code and Percentage': {'Entity': 'EA at 1.000000% EZ at 1.000000% EN at 98.000000%', 'Page': [19], 'Offset': [119, 167], 'Risk Code': ['EA', 'EZ', 'EN'], 'Risk Percent': ['1.000000%', '1.000000%', '98.000000%']}}, {'Risk Code and Percentage': {'Entity': 'EA at 1.000000% EZ at 1.000000% EN at 98.000000%', 'Page': [19], 'Offset': [119, 167], 'Risk Code': ['EA', 'EZ', 'EN'], 'Risk Percent': ['1.000000%', '1.000000%', '98.000000%']}}]
            sample = [{'Risk Code and Percentage': {'Entity': '99% CY 1% 7T', 'Page': [57], 'Offset': [524, 536], 'Risk Code': ['CY', '7T'], 'Risk Percent': ['99%', '1%']}}]
#             print(b)
            for ind, elem in enumerate(b):
                if (b[ind]["Risk Code and Percentage"]["Risk Percent"] != None):
                    b[ind]["Risk Code and Percentage"]["Risk Code"] = list(
                        set(b[ind]["Risk Code and Percentage"]["Risk Code"]))
                else:
                    pass
            print('riskcode and risk percentage output----',b)
            original_rcodes = b
            print(b)
            print(len(b) == meta_data[0])
            print("Output from risk codes section")

            if len(b) == meta_data[0]:

                print("edada")

            try:
                print("Entering to Update Risk Codes")
                group_no = 0
                for key_1, value_1 in meta_data[5].items():
                    group_no = group_no + 1
                    subgroup_no = 0
                    p_riskcodes = []
                    for key_2, val_2 in value_1.items():
                        for kk in ref_out:
                            for keyy, valuee in kk.items():
                                if keyy == val_2:
                                    if valuee["Risk_Code"] == '':
                                        pass
                                    else:
                                        if type(valuee["Risk_Code"]) == list:
                                            if len((valuee["Risk_Code"])) > 0:
                                                p_riskcodes.append((valuee["Risk_Code"]))
                                        else:
                                            p_riskcodes.append((valuee["Risk_Code"]))

                    #                 if len(p_riskcodes)==0:
                    #                     p_riskcodes.append(b[group_no-1]["Risk Code and Percentage"]["Risk Code"])

                    if len(p_riskcodes) > 0:
                        p_risk = []
                        for p_elem in p_riskcodes:
                            p_risk = p_risk + p_elem
                        p_risk = list(set(p_risk))
                        for elem_risk in p_risk:
                            if elem_risk in valid_riskcode_meta:
                                match_per = False
                                for element in b:
                                    for key_d, value_d in element.items():
                                        for ind, ele in enumerate(value_d["Risk Code"]):
                                            if ele == elem_risk and match_per == False:
                                                subgroup_no = subgroup_no + 1
                                                try:
                                                    coordinate = get_coordinates2(df, int(
                                                        value_d['Page'][0]), value_d['Offset'][0], value_d['Offset'][1])
                                                    #                                                     page = df_output.at[j,"value_page"]
                                                    xmin = coordinate['xmin']
                                                    ymin = coordinate['ymin']
                                                    xmax = coordinate['xmax']
                                                    ymax = coordinate['ymax']
                                                except:
                                                    xmin, ymin, xmax, ymax = "NA", "NA", "NA", "NA"
                                                db_op.loc[len(db_op)] = [
                                                    filename,
                                                    '',
                                                    'RiskCodeValue',
                                                    '',
                                                    key_1,
                                                    key_1,
                                                    round(int(group_no), 0),
                                                    round(int(subgroup_no), 0),
                                                    ele,
                                                    ele,
                                                    value_d['Page'][0],
                                                    xmin,
                                                    ymin,
                                                    xmax,
                                                    ymax,
                                                    value_d['Offset'][0], value_d['Offset'][1],
                                                    '0.83', 0,
                                                    0,
                                                    0,
                                                    0,
                                                    0
                                                ]
                                                try:
                                                    risk_per = clean_percentage_int_risk(
                                                        str(value_d["Risk Percent"][ind]))
                                                    #                                                     print(str(value_d["Risk Percent"][ind]))
                                                    #                                                     print(risk_per)
                                                    #                                                     #print("erisk_per")

                                                    if risk_per != "":
                                                        try:
                                                            coordinate = get_coordinates2(df,
                                                                                                               int(
                                                                                                                   value_d[
                                                                                                                       'Page'][
                                                                                                                       0]),
                                                                                                               value_d[
                                                                                                                   'Offset'][
                                                                                                                   0],
                                                                                                               value_d[
                                                                                                                   'Offset'][
                                                                                                                   1])
                                                            #                                                     page = df_output.at[j,"value_page"]
                                                            xmin = coordinate['xmin']
                                                            ymin = coordinate['ymin']
                                                            xmax = coordinate['xmax']
                                                            ymax = coordinate['ymax']
                                                        except:
                                                            xmin, ymin, xmax, ymax = "NA", "NA", "NA", "NA"
                                                        db_op.loc[len(db_op)] = [
                                                            filename,
                                                            '',
                                                            'RiskCodePremsplit',
                                                            '',
                                                            key_1,
                                                            key_1,
                                                            round(int(group_no), 0),
                                                            round(int(subgroup_no), 0),
                                                            risk_per,
                                                            value_d["Risk Percent"][ind],
                                                            value_d['Page'][0],
                                                            xmin,
                                                            ymin,
                                                            xmax,
                                                            ymax,
                                                            value_d['Offset'][0], value_d['Offset'][1],
                                                            '0.83', 0,
                                                            0,
                                                            0,
                                                            0,
                                                            0
                                                        ]
                                                        match_per = True

                                                except Exception as e:
                                                    print(e)
                    else:
                        used_riskcodes = []
                        for element in b:
                            for key_d, value_d in element.items():
                                for ind, ele in enumerate(value_d["Risk Code"]):
                                    if (ele in valid_riskcode_meta) and (ele not in used_riskcodes):
                                        used_riskcodes.append(ele)
                                        
                                        subgroup_no = subgroup_no + 1
                                        try:
                                            coordinate = get_coordinates2(df,
                                                                                               int(value_d['Page'][0]),
                                                                                               value_d['Offset'][0],
                                                                                               value_d['Offset'][1])
                                            #                                                     page = df_output.at[j,"value_page"]
                                            xmin = coordinate['xmin']
                                            ymin = coordinate['ymin']
                                            xmax = coordinate['xmax']
                                            ymax = coordinate['ymax']
                                        except:
                                            xmin, ymin, xmax, ymax = "NA", "NA", "NA", "NA"
                                        db_op.loc[len(db_op)] = [
                                            filename,
                                            '',
                                            'RiskCodeValue',
                                            '',
                                            key_1,
                                            key_1,
                                            round(int(group_no), 0),
                                            round(int(subgroup_no), 0),
                                            ele,
                                            ele,
                                            value_d['Page'][0],
                                            xmin,
                                            ymin,
                                            xmax,
                                            ymax,
                                            value_d['Offset'][0], value_d['Offset'][1],
                                            '0.83', 0,
                                            0,
                                            0,
                                            0,
                                            0
                                        ]

                                        try:
                                            risk_per = clean_percentage_int_risk(str(value_d["Risk Percent"][ind]))
                                            if risk_per != '':
                                                try:
                                                    coordinate = get_coordinates2(df, int(
                                                        value_d['Page'][0]), value_d['Offset'][0], value_d['Offset'][1])
                                                    #                                                     page = df_output.at[j,"value_page"]
                                                    xmin = coordinate['xmin']
                                                    ymin = coordinate['ymin']
                                                    xmax = coordinate['xmax']
                                                    ymax = coordinate['ymax']
                                                except:
                                                    xmin, ymin, xmax, ymax = "NA", "NA", "NA", "NA"
                                                db_op.loc[len(db_op)] = [
                                                    filename,
                                                    '',
                                                    'RiskCodePremsplit',
                                                    '',
                                                    key_1,
                                                    key_1,
                                                    round(int(group_no), 0),
                                                    round(int(subgroup_no), 0),
                                                    risk_per,
                                                    value_d["Risk Percent"][ind],
                                                    value_d['Page'][0],
                                                    xmin,
                                                    ymin,
                                                    xmax,
                                                    ymax,
                                                    value_d['Offset'][0], value_d['Offset'][1],
                                                    '0.83', 0,
                                                    0,
                                                    0,
                                                    0,
                                                    0
                                                ]
                                        except:
                                            pass

        except Exception as e:
            ##print("eError in Risk Code Module")
            print(e)
