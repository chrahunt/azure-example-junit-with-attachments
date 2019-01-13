<?xml version="1.0" encoding="UTF-8"?>
<!-- From https://github.com/artberri/junit-to-nunit/blob/1a000edd1a5c8ffd0c83a16de632e4cc897200d8/junit-to-nunit.xsl
     
     This file is licensed under GPLv2 per https://github.com/artberri/junit-to-nunit/blob/1a000edd1a5c8ffd0c83a16de632e4cc897200d8/LICENSE.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xalan="http://xml.apache.org/xslt">
    <xsl:output method="xml"
                indent="yes"
                xalan:indent-amount="4"
                cdata-section-elements="message stack-trace"/>

    <xsl:template match="/">
        <xsl:variable name="skipped" select="count(//skipped)"/>
        <xsl:variable name="failed" select="count(//error) + count(//failure)"/>
        <xsl:variable name="total" select="count(//testcase)"/>
        <xsl:variable name="passed" select="$total - $failed - $skipped"/>
        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="$failed > 0">Failed</xsl:when>
                <xsl:when test="$passed = 0">Skipped</xsl:when>
                <xsl:otherwise>Passed</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <test-run duration="{//testsuite[1]/@time}"
                  failed="{$failed}"
                  fullname="tests"
                  id="2"
                  inconclusive="0"
                  name="tests"
                  asserts="0"
                  random-seed="0"
                  passed="{$passed}"
                  result="{$result}"
                  skipped="{$skipped}"
                  testcasecount="{$total}"
                  total="{$total}">
            <command-line/>
            <filter/>
            <xsl:apply-templates select="testsuite"/>

            <xsl:for-each select="testsuites">
                <xsl:apply-templates select="testcase"/>
                <xsl:apply-templates select="testsuite"/>
            </xsl:for-each>
        </test-run>
    </xsl:template>

    <xsl:template match="testcase">
        <xsl:param name="assembly_id" tunnel="yes"/>

        <xsl:variable name="asserts">
            <xsl:choose>
                <xsl:when test="@assertions != ''">
                    <xsl:value-of select="@assertions"></xsl:value-of>
                </xsl:when>
                <xsl:when test="count(skipped) > 0"></xsl:when>
                <xsl:when test="count(*) > 0">0</xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="time">
            <xsl:choose>
                <xsl:when test="count(skipped) > 0"></xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@time"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="success">
            <xsl:choose>
                <xsl:when test="count(skipped) > 0"></xsl:when>
                <xsl:when test="count(*) > 0">False</xsl:when>
                <xsl:otherwise>True</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="executed">
            <xsl:choose>
                <xsl:when test="count(skipped) > 0">False</xsl:when>
                <xsl:otherwise>True</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="count(skipped) > 0">Skipped</xsl:when>
                <xsl:when test="count(*) > 0">Failed</xsl:when>
                <xsl:otherwise>Passed</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="stdout" select="system-out"/>

        <xsl:variable name="testcase_id" select="position()"/>

        <test-case id="{$assembly_id}-{$testcase_id}"
                   asserts="{$asserts}"
                   classname="{@classname}"
                   duration="{$time}"
                   fullname="{@name}"
                   name="{@name}"
                   result="{$result}"
                   runstate="Runnable"
                   seed="0"
                   >
            <attachments>
                <xsl:analyze-string
                    select="$stdout"
                    regex="\[\[ATTACHMENT\|([^\]]+?)\]\]">
                    <xsl:matching-substring>
                        <attachment>
                            <filePath><xsl:value-of select="regex-group(1)"/></filePath>
                        </attachment>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </attachments>
            <xsl:apply-templates select="error"/>
            <xsl:apply-templates select="failure"/>
            <xsl:apply-templates select="skipped"/>
        </test-case>
    </xsl:template>

    <xsl:template match="testsuite">
        <xsl:variable name="skipped" select="count(//skipped)"/>
        <xsl:variable name="failed" select="count(.//error) + count(.//failure)"/>
        <xsl:variable name="total" select="count(.//testcase)"/>
        <xsl:variable name="passed" select="$total - $failed - $skipped"/>
        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="$failed > 0">Failed</xsl:when>
                <xsl:when test="$passed = 0">Skipped</xsl:when>
                <xsl:otherwise>Passed</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="assembly_id" select="position()"/>

        <test-suite asserts="0"
                    duration="{@time}"
                    failed="{$failed}"
                    fullname="{@name}"
                    id="{$assembly_id}-0"
                    inconclusive="0"
                    name="{@name}"
                    passed="{$passed}"
                    result="{$result}"
                    runstate="Runnable"
                    skipped="{$skipped}"
                    testcasecount="{$total}"
                    total="{$total}"
                    type="Assembly"
                    warnings="0"
                    >
            <xsl:if test="@file != ''">
                <properties>
                    <property name="file" value="{@file}"/>
                </properties>
            </xsl:if>
            <xsl:apply-templates select="testcase">
                <xsl:with-param name="assembly_id" select="$assembly_id" tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="testsuite"/>
        </test-suite>
    </xsl:template>

    <xsl:template match="error">
        <xsl:variable name="message">
            <xsl:choose>
                <xsl:when test="@message != ''">
                    <xsl:value-of select="@message"/>
                </xsl:when>
                <xsl:when test="@type != ''">
                    <xsl:value-of select="@type"/>
                </xsl:when>
                <xsl:otherwise>No message</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="stacktrace">
            <xsl:choose>
                <xsl:when test="text() != ''">
                    <xsl:value-of select="text()"></xsl:value-of>
                </xsl:when>
                <xsl:when test="@type != ''">
                    <xsl:value-of select="@type"></xsl:value-of>
                </xsl:when>
                <xsl:otherwise>No stack trace</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <failure>
            <message><xsl:value-of select="$message"></xsl:value-of></message>
            <stack-trace><xsl:value-of select="$stacktrace"></xsl:value-of></stack-trace>
        </failure>
    </xsl:template>

    <xsl:template match="failure">
        <xsl:variable name="message">
            <xsl:choose>
                <xsl:when test="@message != ''">
                    <xsl:value-of select="@message"/>
                </xsl:when>
                <xsl:when test="@type != ''">
                    <xsl:value-of select="@type"/>
                </xsl:when>
                <xsl:otherwise>No message</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="stacktrace">
            <xsl:choose>
                <xsl:when test="text() != ''">
                    <xsl:value-of select="text()"/>
                </xsl:when>
                <xsl:when test="@type != ''">
                    <xsl:value-of select="@type"/>
                </xsl:when>
                <xsl:otherwise>No stack trace</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <failure>
            <message><xsl:value-of select="$message"/></message>
            <stack-trace><xsl:value-of select="$stacktrace"/></stack-trace>
        </failure>
    </xsl:template>

    <xsl:template match="skipped">
        <reason>
            <message>Skipped</message>
        </reason>
    </xsl:template>
</xsl:stylesheet>
