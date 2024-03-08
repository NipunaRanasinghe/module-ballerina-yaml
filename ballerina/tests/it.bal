// Copyright (c) 2022, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ballerina/io;
import ballerina/test;

YamlType[] customYamlTypes = [];
map<FailSafeSchema> customTags = {
    "!": STRING,
    "!foo": STRING,
    "tag:example.com,2000:app/foo": STRING,
    "tag:yaml.org,2002:set": MAPPING,
    "tag:yaml.org,2002:binary": STRING,
    "!my-light": STRING,
    "!local": STRING,
    "!bar": STRING,
    "tag:clarkevans.com,2002:shape": SEQUENCE,
    "tag:clarkevans.com,2002:circle": MAPPING,
    "tag:clarkevans.com,2002:line": MAPPING,
    "tag:clarkevans.com,2002:label": MAPPING,
    "tag:yaml.org,2002:omap": SEQUENCE,
    "tag:example.com,2000:app/int": STRING,
    "tag:example.com,2000:app/tag!": STRING,
    "tag:example.com,2011:A": STRING
};

@test:BeforeSuite
function initYamlCustomTypes() {
    customTags.entries().forEach(function([string, FailSafeSchema] entry) {
        customYamlTypes.push({
            tag: entry[0],
            ballerinaType: string,
            kind: entry[1],
            construct: isolated function(json data) returns json => data,
            represent: isolated function(json data) returns string => data.toString()
        });
    });
}

@test:Config {
    dataProvider: yamlDataGen
}
function testYAMLIntegrationTestForReadFile(string filePath, json expectedOutput, boolean isStream, boolean isError) returns error? {
    json|Error output = readFile(filePath, yamlTypes = customYamlTypes, isStream = isStream);
    assertOutput(output, expectedOutput, isError);
}

@test:Config {
    dataProvider: yamlDataGen
}
function testYAMLIntegrationTestForReadString(string filePath, json expectedOutput, boolean isStream, boolean isError) returns error? {
    io:ReadableByteChannel byteChannel = check io:openReadableFile(filePath);
    (byte[] & readonly) readBytes = check byteChannel.readAll();
    string yamlContent = check string:fromBytes(readBytes);

    json|Error output = readString(yamlContent, yamlTypes = customYamlTypes, isStream = isStream);
    assertOutput(output, expectedOutput, isError);
}

function assertOutput(json|Error actualOut, json expectedOut, boolean isError) {
    if isError {
        test:assertTrue(actualOut is Error);
    } else {
        test:assertEquals(actualOut, expectedOut);
    }
}
