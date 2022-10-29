#disable-next-line secure-secrets-in-params   // Doesn't contain a secret - just a relevant name for the resource.
param logicappname string = 'Automated-Secret-Expiry-Notification' // This is just the default name
param location string = resourceGroup().location
param sender_email_address string = 'alerts@customertenant.com'
param recipient_email_address string = 'support@yourtenant.com'
param microsoft_graph_url string = 'https://graph.microsoft.com/v1.0/users/${sender_email_address}/sendMail'

resource workflows_Secret_Expiry_Notification_name_resource 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicappname
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
      }
      triggers: {
        Recurrence: {
          recurrence: {
            frequency: 'Month'
            interval: 1
          }
          evaluatedRecurrence: {
            frequency: 'Month'
            interval: 1
          }
          type: 'Recurrence'
        }
      }
      actions: {
        Append_to_variable_html: {
          runAfter: {
            Do_Until: [
              'Succeeded'
            ]
          }
          type: 'AppendToStringVariable'
          inputs: {
            name: 'html'
            value: '<tbody></table>'
          }
        }
        Do_Until: {
          actions: {
            'For_each_-_apps': {
              foreach: '@body(\'Parse_JSON\')?[\'value\']'
              actions: {
                'For_each_-_keyCreds': {
                  foreach: '@variables(\'keyCredentials\')'
                  actions: {
                    'Future_time_is_greater_than_endDate_-_keyCreds': {
                      foreach: '@items(\'For_each_-_apps\')[\'keyCredentials\']'
                      actions: {
                        Condition_2: {
                          actions: {
                            Append_to_string_variable_2: {
                              runAfter: {
                                Set_variable_6: [
                                  'Succeeded'
                                ]
                              }
                              type: 'AppendToStringVariable'
                              inputs: {
                                name: 'html'
                                value: '<tr><td @{variables(\'styles\').cellStyle}><a href="https://ms.portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/Credentials/appId/@{variables(\'appId\')}/isMSAApp/">@{variables(\'appId\')}</a></td><td @{variables(\'styles\').cellStyle}>@{variables(\'displayName\')}</td><td @{if(less(variables(\'daystilexpiration\'), 15), variables(\'styles\').redStyle, if(less(variables(\'daystilexpiration\'), 30), variables(\'styles\').yellowStyle, variables(\'styles\').cellStyle))}>@{variables(\'daystilexpiration\')} </td><td @{variables(\'styles\').cellStyle}>Certificate</td><td @{variables(\'styles\').cellStyle}>@{formatDateTime(item()?[\'endDateTime\'], \'g\')}</td></tr>'
                              }
                            }
                            DifferenceAsDays_2: {
                              runAfter: {
                                StartTimeTickValue_2: [
                                  'Succeeded'
                                ]
                              }
                              type: 'Compose'
                              inputs: '@div(div(div(mul(sub(outputs(\'EndTimeTickValue_2\'), outputs(\'StartTimeTickValue_2\')), 100), 1000000000), 3600), 24)\n'
                            }
                            EndTimeTickValue_2: {
                              runAfter: {
                              }
                              type: 'Compose'
                              inputs: '@ticks(item()?[\'endDateTime\'])\n'
                            }
                            Set_variable_6: {
                              runAfter: {
                                DifferenceAsDays_2: [
                                  'Succeeded'
                                ]
                              }
                              type: 'SetVariable'
                              inputs: {
                                name: 'daystilexpiration'
                                value: '@outputs(\'DifferenceAsDays_2\')'
                              }
                            }
                            StartTimeTickValue_2: {
                              runAfter: {
                                EndTimeTickValue_2: [
                                  'Succeeded'
                                ]
                              }
                              type: 'Compose'
                              inputs: '@ticks(utcnow())\n'
                            }
                          }
                          runAfter: {
                          }
                          expression: {
                            and: [
                              {
                                greaterOrEquals: [
                                  '@body(\'Get_future_time\')'
                                  ''
                                ]
                              }
                            ]
                          }
                          type: 'If'
                        }
                      }
                      runAfter: {
                      }
                      type: 'Foreach'
                    }
                  }
                  runAfter: {
                    'For_each_-_passwordCreds': [
                      'Succeeded'
                    ]
                  }
                  type: 'Foreach'
                }
                'For_each_-_passwordCreds': {
                  foreach: '@variables(\'passwordCredentials\')'
                  actions: {
                    'Future_time_is_greater_than_endDate_-_passwordCreds': {
                      foreach: '@items(\'For_each_-_apps\')[\'passwordCredentials\']'
                      actions: {
                        Condition: {
                          actions: {
                            Append_to_string_variable: {
                              runAfter: {
                                Set_variable_5: [
                                  'Succeeded'
                                ]
                              }
                              type: 'AppendToStringVariable'
                              inputs: {
                                name: 'html'
                                value: '<tr><td @{variables(\'styles\').cellStyle}><a href="https://ms.portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/Credentials/appId/@{variables(\'appId\')}/isMSAApp/">@{variables(\'appId\')}</a></td><td @{variables(\'styles\').cellStyle}>@{variables(\'displayName\')}</td><td @{if(less(variables(\'daystilexpiration\'),15),variables(\'styles\').redStyle,if(less(variables(\'daystilexpiration\'),30),variables(\'styles\').yellowStyle,variables(\'styles\').cellStyle))}>@{variables(\'daystilexpiration\')} </td><td @{variables(\'styles\').cellStyle}>Secret</td><td @{variables(\'styles\').cellStyle}>@{formatDateTime(item()?[\'endDateTime\'],\'g\')}</td></tr>'
                              }
                            }
                            DifferenceAsDays: {
                              runAfter: {
                                StartTimeTickValue: [
                                  'Succeeded'
                                ]
                              }
                              type: 'Compose'
                              inputs: '@div(div(div(mul(sub(outputs(\'EndTimeTickValue\'),outputs(\'StartTimeTickValue\')),100),1000000000), 3600), 24)\n'
                            }
                            EndTimeTickValue: {
                              runAfter: {
                              }
                              type: 'Compose'
                              inputs: '@ticks(item()?[\'endDateTime\'])\n'
                            }
                            Set_variable_5: {
                              runAfter: {
                                DifferenceAsDays: [
                                  'Succeeded'
                                ]
                              }
                              type: 'SetVariable'
                              inputs: {
                                name: 'daystilexpiration'
                                value: '@outputs(\'DifferenceAsDays\')'
                              }
                            }
                            StartTimeTickValue: {
                              runAfter: {
                                EndTimeTickValue: [
                                  'Succeeded'
                                ]
                              }
                              type: 'Compose'
                              inputs: '@ticks(utcnow())\n'
                            }
                          }
                          runAfter: {
                          }
                          expression: {
                            and: [
                              {
                                greaterOrEquals: [
                                  '@body(\'Get_future_time\')'
                                  ''
                                ]
                              }
                            ]
                          }
                          type: 'If'
                        }
                      }
                      runAfter: {
                      }
                      type: 'Foreach'
                    }
                  }
                  runAfter: {
                    Set_variable_4: [
                      'Succeeded'
                    ]
                  }
                  type: 'Foreach'
                }
                Set_variable: {
                  runAfter: {
                  }
                  type: 'SetVariable'
                  inputs: {
                    name: 'passwordCredentials'
                    value: '@items(\'For_each_-_apps\')?[\'passwordCredentials\']'
                  }
                }
                Set_variable_2: {
                  runAfter: {
                    Set_variable: [
                      'Succeeded'
                    ]
                  }
                  type: 'SetVariable'
                  inputs: {
                    name: 'appId'
                    value: '@items(\'For_each_-_apps\')?[\'appId\']'
                  }
                }
                Set_variable_3: {
                  runAfter: {
                    Set_variable_2: [
                      'Succeeded'
                    ]
                  }
                  type: 'SetVariable'
                  inputs: {
                    name: 'displayName'
                    value: '@items(\'For_each_-_apps\')?[\'displayName\']'
                  }
                }
                Set_variable_4: {
                  runAfter: {
                    Set_variable_3: [
                      'Succeeded'
                    ]
                  }
                  type: 'SetVariable'
                  inputs: {
                    name: 'keyCredentials'
                    value: '@items(\'For_each_-_apps\')?[\'keyCredentials\']'
                  }
                }
              }
              runAfter: {
                Get_future_time: [
                  'Succeeded'
                ]
              }
              type: 'Foreach'
            }
            Get_future_time: {
              runAfter: {
                Parse_JSON: [
                  'Succeeded'
                ]
              }
              type: 'Expression'
              kind: 'GetFutureTime'
              inputs: {
                interval: 60
                timeUnit: 'Day'
              }
            }
            HTTP: {
              runAfter: {
              }
              type: 'Http'
              inputs: {
                authentication: {
                  audience: 'https://graph.microsoft.com'
                  type: 'ManagedServiceIdentity'
                }
                method: 'GET'
                uri: '@variables(\'NextLink\')'
              }
            }
            Parse_JSON: {
              runAfter: {
                HTTP: [
                  'Succeeded'
                ]
              }
              type: 'ParseJson'
              inputs: {
                content: '@body(\'HTTP\')'
                schema: {
                  properties: {
                    '@@odata.context': {
                      type: 'string'
                    }
                    '@@odata.nextLink': {
                      type: 'string'
                    }
                    value: {
                      items: {
                        properties: {
                          appId: {
                            type: 'string'
                          }
                          displayName: {
                            type: 'string'
                          }
                          keyCredentials: {
                            items: {
                              properties: {
                                customKeyIdentifier: {
                                }
                                displayName: {
                                }
                                endDateTime: {
                                }
                                key: {
                                }
                                keyId: {
                                }
                                startDateTime: {
                                }
                                type: {
                                }
                                usage: {
                                }
                              }
                              required: []
                              type: 'object'
                            }
                            type: 'array'
                          }
                          passwordCredentials: {
                            items: {
                              properties: {
                                customKeyIdentifier: {
                                }
                                displayName: {
                                }
                                endDateTime: {
                                }
                                hint: {
                                }
                                keyId: {
                                }
                                secretText: {
                                }
                                startDateTime: {
                                }
                              }
                              required: []
                              type: 'object'
                            }
                            type: 'array'
                          }
                        }
                        required: []
                        type: 'object'
                      }
                      type: 'array'
                    }
                  }
                  type: 'object'
                }
              }
            }
            Set_NextLink: {
              runAfter: {
                'For_each_-_apps': [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'NextLink'
                value: '@body(\'Parse_JSON\')?[\'@odata.nextLink\']'
              }
            }
          }
          runAfter: {
            Initialize_NextLink: [
              'Succeeded'
            ]
          }
          expression: '@empty(variables(\'NextLink\'))'
          limit: {
            count: 60
            timeout: 'PT1H'
          }
          type: 'Until'
        }
        HTTP_2: {
          runAfter: {
            Append_to_variable_html: [
              'Succeeded'
            ]
          }
          type: 'Http'
          inputs: {
            authentication: {
              audience: 'https://graph.microsoft.com'
              type: 'ManagedServiceIdentity'
            }
            body: {
              message: {
                body: {
                  content: '@{variables(\'html\')}'
                  contentType: 'HTML'
                }
                subject: 'Exipring Secrets'
                toRecipients: [
                  {
                    emailAddress: {
                      address: recipient_email_address
                    }
                  }
                ]
              }
              saveToSentItems: 'true'
            }
            method: 'POST'
            uri: microsoft_graph_url
          }
        }
        Initialize_NextLink: {
          runAfter: {
            'Initialize_variable_-_daystilexpiration': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'NextLink'
                type: 'string'
                value: 'https://graph.microsoft.com/v1.0/applications?$select=appId,displayName,passwordCredentials,keyCredentials&$top=999'
              }
            ]
          }
        }
        Initialize_appid: {
          runAfter: {
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'appId'
                type: 'string'
              }
            ]
          }
        }
        Initialize_displayName: {
          runAfter: {
            Initialize_appid: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'displayName'
                type: 'string'
              }
            ]
          }
        }
        'Initialize_variable_-_daystilexpiration': {
          runAfter: {
            'Initialize_variable_-html': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'daystilexpiration'
                type: 'float'
              }
            ]
          }
        }
        'Initialize_variable_-_keyCredentials': {
          runAfter: {
            'Initialize_variable_-_passwordCredentials': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'keyCredentials'
                type: 'array'
              }
            ]
          }
        }
        'Initialize_variable_-_passwordCredentials': {
          runAfter: {
            Initialize_displayName: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'passwordCredentials'
                type: 'array'
              }
            ]
          }
        }
        'Initialize_variable_-_styles': {
          runAfter: {
            'Initialize_variable_-_keyCredentials': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'styles'
                type: 'object'
                value: {
                  cellStyle: 'style="font-family: Calibri; padding: 5px; border: 1px solid black;"'
                  headerStyle: 'style="font-family: Helvetica; padding: 5px; border: 1px solid black;"'
                  redStyle: 'style="background-color:red; font-family: Calibri; padding: 5px; border: 1px solid black;"'
                  tableStyle: 'style="border-collapse: collapse;"'
                  yellowStyle: 'style="background-color:yellow; font-family: Calibri; padding: 5px; border: 1px solid black;"'
                }
              }
            ]
          }
        }
        'Initialize_variable_-html': {
          runAfter: {
            'Initialize_variable_-_styles': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'html'
                type: 'string'
                value: '<table @{variables(\'styles\').tableStyle}><thead><th @{variables(\'styles\').headerStyle}>Application ID</th><th @{variables(\'styles\').headerStyle}>Display Name</th><th @{variables(\'styles\').headerStyle}>Days until Expiration</th><th @{variables(\'styles\').headerStyle}>Type</th><th @{variables(\'styles\').headerStyle}>Expiration Date</th></thead><tbody>'
              }
            ]
          }
        }
      }
      outputs: {
      }
    }
    parameters: {
    }
  }
}
