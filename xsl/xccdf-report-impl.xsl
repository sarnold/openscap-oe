<?xml version="1.0" encoding="utf-8" ?>

<!--
Copyright 2010-2014 Red Hat Inc., Durham, North Carolina.
All Rights Reserved.

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

Authors:
     Martin Preisler <mpreisle@redhat.com>
     Lukas Kuklinek <lkuklinek@redhat.com>
-->

<xsl:stylesheet version="1.1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cdf="http://checklists.nist.gov/xccdf/1.2"
    xmlns:ovalres="http://oval.mitre.org/XMLSchema/oval-results-5"
    xmlns:sceres="http://open-scap.org/page/SCE_result_file"
    xmlns:exsl="http://exslt.org/common"
    xmlns:arf="http://scap.nist.gov/schema/asset-reporting-format/1.1"
    exclude-result-prefixes="xsl cdf ovalres sceres exsl arf">

<!-- This selects all the references, even if the SDS has multiple benchmarks.
     That is fine because we will go through just the benchmark references
     and only then we compare to this map. So this is correct.
     See template "get-all-references". -->
<xsl:key name="references" match="//cdf:reference" use="@href"/>

<xsl:include href="xccdf-branding.xsl" />
<xsl:include href="xccdf-references.xsl" />
<xsl:include href="xccdf-resources.xsl" />
<xsl:include href="xccdf-share.xsl" />

<xsl:include href="xccdf-report-oval-details.xsl" />

<xsl:output
    method="html"
    encoding="utf-8"
    indent="no"
    omit-xml-declaration="yes"/>

<xsl:template name="introduction">
    <xsl:param name="benchmark"/>
    <xsl:param name="profile"/>

    <div id="introduction">
        <div class="row">
            <xsl:call-template name="show-title-front-matter-description-notices">
                <xsl:with-param name="benchmark" select="$benchmark"/>
                <xsl:with-param name="profile" select="$profile"/>
            </xsl:call-template>
        </div>
    </div>
</xsl:template>

<xsl:template name="characteristics">
    <xsl:param name="testresult"/>
    <xsl:param name="benchmark"/>
    <xsl:param name="profile"/>

    <div id="characteristics">
        <h2>Evaluation Characteristics</h2>
        <div class="row">
            <div class="col-md-5 well well-lg horizontal-scroll">
                <table class="table table-bordered">
                    <tr>
                        <th>Evaluation target</th>
                        <td>
                            <xsl:value-of select="$testresult/cdf:target/text()"/>
                        </td>
                    </tr>
                    <xsl:if test="$testresult/cdf:target-facts/cdf:fact[@name = 'urn:xccdf:fact:identifier']">
                        <tr>
                            <th>Target ID</th>
                            <td><xsl:value-of select="$testresult/cdf:target-facts/cdf:fact[@name = 'urn:xccdf:fact:identifier']/text()"/></td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="$testresult/cdf:benchmark">
                        <tr>
                            <th>Benchmark URL</th>
                            <td><xsl:value-of select="$testresult/cdf:benchmark/@href"/></td>
                        </tr>
                        <xsl:if test="$testresult/cdf:benchmark/@id">
                            <tr>
                                <th>Benchmark ID</th>
                                <td><xsl:value-of select="$testresult/cdf:benchmark/@id"/></td>
                            </tr>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$benchmark/cdf:version">
                        <tr>
                            <th>Benchmark version</th>
                            <td><xsl:value-of select="$benchmark/cdf:version[1]/text()"/></td>
                        </tr>
                    </xsl:if>
                    <xsl:if test="$testresult/cdf:profile">
                        <tr>
                            <th>Profile ID</th>
                            <td><xsl:value-of select="$testresult/cdf:profile/@idref"/></td>
                        </tr>
                    </xsl:if>
                    <tr>
                        <th>Started at</th>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$testresult/@start-time">
                                    <xsl:value-of select="$testresult/@start-time"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    unknown time
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                    <tr>
                        <th>Finished at</th>
                        <td>
                            <xsl:value-of select="$testresult/@end-time"/>
                        </td>
                    </tr>
                    <tr>
                        <th>Performed by</th>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$testresult/cdf:identity">
                                    <xsl:value-of select="$testresult/cdf:identity/text()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    unknown user
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                    <tr>
                        <th>Test system</th>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$testresult/@test-system">
                                    <xsl:value-of select="$testresult/@test-system"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    unknown
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="col-md-3 horizontal-scroll">
                <h4>CPE Platforms</h4>
                <ul class="list-group">
                    <!-- all the applicable platforms first -->
                    <xsl:for-each select="$benchmark/cdf:platform">
                        <xsl:variable name="idref" select="@idref"/>
                        <xsl:if test="$testresult/cdf:platform[@idref=$idref]">
                            <li class="list-group-item">
                                <span class="label label-success" title="CPE platform {@idref} was found applicable on the evaluated machine"><xsl:value-of select="@idref"/></span>
                            </li>
                        </xsl:if>
                    </xsl:for-each>
                    <!-- then the rest -->
                    <xsl:for-each select="$benchmark/cdf:platform">
                        <xsl:variable name="idref" select="@idref"/>
                        <xsl:if test="not($testresult/cdf:platform[@idref=$idref])">
                            <li class="list-group-item">
                                <span class="label label-default" title="This CPE platform was not applicable on the evaluated machine"><xsl:value-of select="@idref"/></span>
                            </li>
                        </xsl:if>
                    </xsl:for-each>
                </ul>
            </div>
            <div class="col-md-4 horizontal-scroll">
                <h4>Addresses</h4>
                <ul class="list-group">
                    <!-- the second predicate ensures that we don't print duplicates -->
                    <xsl:for-each select="$testresult/cdf:target-address[not(. = preceding::cdf:target-address)]">
                        <li class="list-group-item">
                            <xsl:choose>
                                <xsl:when test="contains(text(), ':')">
                                    <span class="label label-info">IPv6</span>
                                </xsl:when>
                                <xsl:when test="contains(text(), '.')">
                                    <span class="label label-primary">IPv4</span>
                                </xsl:when>
                                <xsl:otherwise>
                                </xsl:otherwise>
                            </xsl:choose>
                            <!-- #160 is nbsp -->
                            &#160;<xsl:value-of select="text()"/>
                        </li>
                    </xsl:for-each>
                    <!-- the second predicate ensures that we don't print duplicates -->
                    <xsl:for-each select="$testresult/cdf:target-facts/cdf:fact[@name = 'urn:xccdf:fact:ethernet:MAC'][not(. = preceding::cdf:fact)]">
                        <li class="list-group-item">
                            <span class="label label-default">MAC</span>
                            <!-- #160 is nbsp -->
                            &#160;<xsl:value-of select="text()"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </div>
    </div>
</xsl:template>

<xsl:template name="compliance-and-scoring">
    <xsl:param name="testresult"/>

    <div id="compliance-and-scoring">
        <h2>Compliance and Scoring</h2>

        <xsl:variable name="total_rules_count" select="count($testresult/cdf:rule-result[cdf:result])"/>
        <xsl:variable name="ignored_rules_count" select="count($testresult/cdf:rule-result[cdf:result/text() = 'notselected' or cdf:result/text() = 'notapplicable'])"/>
        <xsl:variable name="passed_rules_count" select="count($testresult/cdf:rule-result[cdf:result/text() = 'pass' or cdf:result/text() = 'fixed'])"/>
        <xsl:variable name="failed_rules_count" select="count($testresult/cdf:rule-result[cdf:result/text() = 'fail'])"/>
        <xsl:variable name="uncertain_rules_count" select="count($testresult/cdf:rule-result[cdf:result/text() = 'error' or cdf:result/text() = 'unknown'])"/>
        <xsl:variable name="not_ignored_rules_count" select="$total_rules_count - $ignored_rules_count"/>

        <xsl:choose>
            <xsl:when test="$failed_rules_count > 0">
                <div class="alert alert-danger">
                    <strong>The target system did not satisfy the conditions of <xsl:value-of select="$failed_rules_count"/> rules!</strong>
                    <xsl:if test="$uncertain_rules_count > 0">
                        Furthermore, the results of <xsl:value-of select="$uncertain_rules_count"/> rules were inconclusive.
                    </xsl:if>
                    Please review rule results and consider applying remediation.
                </div>
            </xsl:when>
            <xsl:when test="$uncertain_rules_count > 0">
                <div class="alert alert-warning">
                    <strong>There were no failed rules, but the results of <xsl:value-of select="$uncertain_rules_count"/> rules were inconclusive!</strong>
                    Please review rule results and consider applying remediation.
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="alert alert-success">
                    <strong>There were no failed or uncertain rules.</strong> It seems that no action is necessary.
                </div>
            </xsl:otherwise>
        </xsl:choose>

        <h3>Rule results</h3>
        <xsl:choose>
            <xsl:when test="$not_ignored_rules_count > 0" >
                <div class="progress" title="Displays proportion of passed/fixed, failed/error, and other rules (in that order). There were {$not_ignored_rules_count} rules taken into account.">
                    <div class="progress-bar progress-bar-success" style="width: {$passed_rules_count div $not_ignored_rules_count * 100}%">
                        <xsl:value-of select="$passed_rules_count"/> passed
                    </div>
                    <div class="progress-bar progress-bar-danger" style="width: {$failed_rules_count div $not_ignored_rules_count * 100}%">
                        <xsl:value-of select="$failed_rules_count"/> failed
                    </div>
                    <div class="progress-bar progress-bar-warning" style="width: {(1 - ($passed_rules_count + $failed_rules_count) div $not_ignored_rules_count) * 100}%">
                        <xsl:value-of select="$not_ignored_rules_count - $passed_rules_count - $failed_rules_count"/> other
                    </div>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div>No rules were evaluated.</div>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:variable name="failed_rules_low_severity" select="count($testresult/cdf:rule-result[(cdf:result/text() = 'fail') and (@severity = 'low')])"/>
        <xsl:variable name="failed_rules_medium_severity" select="count($testresult/cdf:rule-result[(cdf:result/text() = 'fail') and (@severity = 'medium')])"/>
        <xsl:variable name="failed_rules_high_severity" select="count($testresult/cdf:rule-result[(cdf:result/text() = 'fail') and (@severity = 'high')])"/>

        <xsl:variable name="failed_rules_other_severity" select="$failed_rules_count - $failed_rules_high_severity - $failed_rules_medium_severity - $failed_rules_low_severity"/>

        <xsl:if test="$failed_rules_count > 0">
            <h3>Severity of failed rules</h3>
            <div class="progress" title="Displays proportion of high, medium, low, and other severity failed rules (in that order). There were {$failed_rules_count} total failed rules.">
                <div class="progress-bar progress-bar-success" style="width: {$failed_rules_other_severity div $failed_rules_count * 100}%">
                    <xsl:value-of select="$failed_rules_other_severity"/> other
                </div>
                <div class="progress-bar progress-bar-info" style="width: {$failed_rules_low_severity div $failed_rules_count * 100}%">
                    <xsl:value-of select="$failed_rules_low_severity"/> low
                </div>
                <div class="progress-bar progress-bar-warning" style="width: {$failed_rules_medium_severity div $failed_rules_count * 100}%">
                    <xsl:value-of select="$failed_rules_medium_severity"/> medium
                </div>
                <div class="progress-bar progress-bar-danger" style="width: {$failed_rules_high_severity div $failed_rules_count * 100}%">
                    <xsl:value-of select="$failed_rules_high_severity"/> high
                </div>
            </div>
        </xsl:if>

        <h3 title="As per the XCCDF specification">Score</h3>
        <table class="table table-striped table-bordered">
            <thead>
                <tr>
                    <th>Scoring system</th>
                    <th class="text-center">Score</th>
                    <th class="text-center">Maximum</th>
                    <th class="text-center" style="width: 40%">Percent</th>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="$testresult/cdf:score">
                    <xsl:variable name="percent" select="(text() div @maximum) * 100"/>
                    <tr>
                        <td><xsl:value-of select="@system"/></td>
                        <td class="text-center"><xsl:value-of select="text()"/></td>
                        <td class="text-center"><xsl:value-of select="@maximum"/></td>
                        <td>
                            <div class="progress">
                                <div class="progress-bar progress-bar-success" style="width: {$percent}%"><xsl:if test="$percent &gt;= 50"><xsl:value-of select="round($percent * 100) div 100"/>%</xsl:if></div>
                                <div class="progress-bar progress-bar-danger" style="width: {100 - $percent}%"><xsl:if test="$percent &lt; 50"><xsl:value-of select="round($percent * 100) div 100"/>%</xsl:if></div>
                            </div>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </div>
</xsl:template>

<xsl:template name="references-to-json">
    <xsl:param name="item"/>
    <xsl:text>{</xsl:text>
    <xsl:for-each select="$item/cdf:reference">
        <xsl:sort select="@href"/>
        <xsl:variable name="href" select="@href"/>
        <xsl:if test="not(preceding-sibling::cdf:reference[@href=$href]) and @href">
            <xsl:if test="position() != 1">
                <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text>"</xsl:text>
            <xsl:call-template name="convert-reference-url-to-name">
                <xsl:with-param name="href" select="$href"/>
            </xsl:call-template>
            <xsl:text>":[</xsl:text>
            <xsl:for-each select="$item/cdf:reference[@href=$href]">
                <xsl:text>"</xsl:text>
                <xsl:choose>
                    <xsl:when test="normalize-space(.)">
                        <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>unknown</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>"</xsl:text>
                <xsl:if test="position() != last()">
                    <xsl:text>,</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>]</xsl:text>
        </xsl:if>
    </xsl:for-each>
    <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template name="rule-overview-leaf-table-row">
    <xsl:param name="result" />
    <xsl:param name="item" />
    <xsl:param name="indent" />
    <xsl:param name="testresult" />
    <xsl:param name="profile" />

    <tr data-tt-id="{$item/@id}" class="rule-overview-leaf rule-overview-leaf-{$result} rule-overview-leaf-id-{$item/@id}" id="rule-overview-leaf-{generate-id(.)}">
        <xsl:attribute name="data-tt-parent-id">
            <xsl:value-of select="$item/parent::cdf:*/@id"/>
        </xsl:attribute>
        <xsl:attribute name="data-references">
            <xsl:call-template name="references-to-json">
                <xsl:with-param name="item" select="$item"/>
            </xsl:call-template>
        </xsl:attribute>
        <xsl:if test="$result = 'fail' or $result = 'error' or $result = 'unknown'">
            <xsl:attribute name="class">rule-overview-leaf rule-overview-leaf-<xsl:value-of select="$result"/> rule-overview-needs-attention</xsl:attribute>
        </xsl:if>

        <td style="padding-left: {$indent * 19}px">
            <a href="#rule-detail-{generate-id(.)}" onclick="return openRuleDetailsDialog('{generate-id(.)}')">
                <xsl:call-template name="item-title">
                    <xsl:with-param name="item" select="$item"/>
                    <xsl:with-param name="testresult" select="$testresult"/>
                    <xsl:with-param name="profile" select="$profile"/>
                </xsl:call-template>
            </a>
            <xsl:if test="cdf:check[@multi-check='true']">
                (<xsl:value-of select="cdf:check/cdf:check-content-ref/@name" />)
            </xsl:if>
            <xsl:if test="cdf:override">
                &#160;<span class="label label-warning">waived</span>
            </xsl:if>
        </td>
        <td class="rule-severity" style="text-align: center">
            <xsl:call-template name="item-severity">
                <xsl:with-param name="item" select="." />
                <xsl:with-param name="profile" select="$profile" />
            </xsl:call-template>
        </td>
        <td class="rule-result rule-result-{$result}">
            <xsl:variable name="result_tooltip">
                <xsl:call-template name="rule-result-tooltip">
                    <xsl:with-param name="ruleresult" select="$result"/>
                </xsl:call-template>
            </xsl:variable>
            <div>
                <abbr title="{$result_tooltip}"><xsl:value-of select="$result"/></abbr>
            </div>
        </td>
    </tr>
</xsl:template>

<xsl:key name="testresult_ruleresults" match="//cdf:rule-result" use="concat(ancestor::cdf:TestResult/@id, '|', @idref)"/>

<xsl:template name="rule-overview-leaf">
    <xsl:param name="testresult"/>
    <xsl:param name="item"/>
    <xsl:param name="profile"/>
    <xsl:param name="indent"/>

    <xsl:variable name="ruleresult" select="key('testresult_ruleresults', concat($testresult/@id, '|', $item/@id))"/>

    <!-- There can be multiple results for 1 XCCDF rule if multi-check is set -->
    <xsl:for-each select="$ruleresult">
        <xsl:variable name="result" select="cdf:result/text()"/>
        <xsl:if test="$result != 'notselected'">
            <xsl:call-template name="rule-overview-leaf-table-row">
                <xsl:with-param name="item" select="$item"/>
                <xsl:with-param name="result" select="$result"/>
                <xsl:with-param name="indent" select="$indent"/>
                <xsl:with-param name="testresult" select="$testresult"/>
                <xsl:with-param name="profile" select="$profile"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:for-each>
</xsl:template>

<xsl:template name="rule-overview-inner-node">
    <xsl:param name="testresult"/>
    <xsl:param name="item"/>
    <xsl:param name="profile"/>
    <xsl:param name="indent"/>

    <xsl:param name="failed_rule_results"/>
    <xsl:param name="error_rule_results"/>
    <xsl:param name="unknown_rule_results"/>
    <xsl:param name="notchecked_rule_results"/>
    <xsl:param name="notselected_rule_results"/>

    <xsl:variable name="descendant_rules" select="$item/descendant::cdf:Rule"/>

    <xsl:variable name="contained_rules_fail" select="count($descendant_rules[@id = $failed_rule_results/@idref])"/>
    <xsl:variable name="contained_rules_error" select="count($descendant_rules[@id = $error_rule_results/@idref])"/>
    <xsl:variable name="contained_rules_unknown" select="count($descendant_rules[@id = $unknown_rule_results/@idref])"/>
    <xsl:variable name="contained_rules_notchecked" select="count($descendant_rules[@id = $notchecked_rule_results/@idref])"/>
    <xsl:variable name="contained_rules_notselected" select="count($descendant_rules[@id = $notselected_rule_results/@idref])"/>
    <xsl:variable name="contained_rules_need_attention" select="$contained_rules_fail + $contained_rules_error + $contained_rules_unknown + $contained_rules_notchecked"/>

    <xsl:if test="$contained_rules_notselected &lt; count($descendant_rules)">
    <tr data-tt-id="{$item/@id}" class="rule-overview-inner-node rule-overview-inner-node-id-{$item/@id}">
        <xsl:if test="$item/parent::cdf:Group or $item/parent::cdf:Benchmark">
            <xsl:attribute name="data-tt-parent-id">
                <xsl:value-of select="$item/parent::cdf:*/@id"/>
            </xsl:attribute>
        </xsl:if>

        <td colspan="3" style="padding-left: {$indent * 19}px">
            <xsl:choose>
                <xsl:when test="$contained_rules_need_attention > 0">
                    <strong>
                        <xsl:call-template name="item-title">
                            <xsl:with-param name="item" select="$item"/>
                            <xsl:with-param name="testresult" select="$testresult"/>
                            <xsl:with-param name="profile" select="$profile"/>
                        </xsl:call-template>
                    </strong>
                    <xsl:if test="$contained_rules_fail > 0">&#160;<span class="badge"><xsl:value-of select="$contained_rules_fail"/>x fail</span></xsl:if>
                    <xsl:if test="$contained_rules_error > 0">&#160;<span class="badge"><xsl:value-of select="$contained_rules_error"/>x error</span></xsl:if>
                    <xsl:if test="$contained_rules_unknown > 0">&#160;<span class="badge"><xsl:value-of select="$contained_rules_unknown"/>x unknown</span></xsl:if>
                    <xsl:if test="$contained_rules_notchecked > 0">&#160;<span class="badge"><xsl:value-of select="$contained_rules_notchecked"/>x notchecked</span></xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="item-title">
                        <xsl:with-param name="item" select="$item"/>
                        <xsl:with-param name="testresult" select="$testresult"/>
                        <xsl:with-param name="profile" select="$profile"/>
                    </xsl:call-template>
                    <script>$(document).ready(function(){$('.treetable').treetable("collapseNode","<xsl:value-of select="$item/@id"/>");});</script>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>

    <xsl:for-each select="$item/cdf:Group">
        <xsl:call-template name="rule-overview-inner-node">
            <xsl:with-param name="testresult" select="$testresult"/>
            <xsl:with-param name="item" select="."/>
            <xsl:with-param name="profile" select="$profile"/>
            <xsl:with-param name="indent" select="$indent + 1"/>

            <xsl:with-param name="failed_rule_results" select="$failed_rule_results"/>
            <xsl:with-param name="error_rule_results" select="$error_rule_results"/>
            <xsl:with-param name="unknown_rule_results" select="$unknown_rule_results"/>
            <xsl:with-param name="notchecked_rule_results" select="$notchecked_rule_results"/>
            <xsl:with-param name="notselected_rule_results" select="$notselected_rule_results"/>
        </xsl:call-template>
    </xsl:for-each>

    <xsl:for-each select="$item/cdf:Rule">
        <xsl:call-template name="rule-overview-leaf">
            <xsl:with-param name="testresult" select="$testresult"/>
            <xsl:with-param name="item" select="."/>
            <xsl:with-param name="profile" select="$profile"/>
            <xsl:with-param name="indent" select="$indent + 1"/>
        </xsl:call-template>
    </xsl:for-each>
    </xsl:if>
</xsl:template>

<xsl:template name="rule-overview">
    <xsl:param name="testresult"/>
    <xsl:param name="benchmark"/>
    <xsl:param name="profile"/>

    <div id="rule-overview">
        <h2>Rule Overview</h2>

        <div class="form-group js-only hidden-print">
            <div class="row">
                <div title="Filter rules by their XCCDF result">
                    <div class="col-sm-2 toggle-rule-display-success">
                        <div class="checkbox">
                            <label><input class="toggle-rule-display" type="checkbox" onclick="toggleRuleDisplay(this)" checked="checked" value="pass"/>pass</label>
                        </div>
                        <div class="checkbox">
                            <label><input class="toggle-rule-display" type="checkbox" onclick="toggleRuleDisplay(this)" checked="checked" value="fixed"/>fixed</label>
                        </div>
                        <div class="checkbox">
                            <label><input class="toggle-rule-display" type="checkbox" onclick="toggleRuleDisplay(this)" checked="checked" value="informational"/>informational</label>
                        </div>
                    </div>

                    <div class="col-sm-2 toggle-rule-display-danger">
                        <div class="checkbox">
                            <label><input class="toggle-rule-display" type="checkbox" onclick="toggleRuleDisplay(this)" checked="checked" value="fail"/>fail</label>
                        </div>
                        <div class="checkbox">
                            <label><input class="toggle-rule-display" type="checkbox" onclick="toggleRuleDisplay(this)" checked="checked" value="error"/>error</label>
                        </div>
                        <div class="checkbox">
                            <label><input class="toggle-rule-display" type="checkbox" onclick="toggleRuleDisplay(this)" checked="checked" value="unknown"/>unknown</label>
                        </div>
                    </div>

                    <div class="col-sm-2 toggle-rule-display-other">
                        <div class="checkbox">
                            <label><input class="toggle-rule-display" type="checkbox" onclick="toggleRuleDisplay(this)" checked="checked" value="notchecked"/>notchecked</label>
                        </div>
                        <div class="checkbox">
                            <label><input class="toggle-rule-display" type="checkbox" onclick="toggleRuleDisplay(this)" checked="checked" value="notapplicable"/>notapplicable</label>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6">
                    <div class="input-group">
                        <input type="text" class="form-control" placeholder="Search through XCCDF rules" id="search-input" oninput="ruleSearch()"/>

                        <div class="input-group-btn">
                            <button class="btn btn-default" onclick="ruleSearch()">Search</button>
                        </div>
                    </div>
                    <p id="search-matches"></p>
                    Group rules by:
                    <select name="groupby" onchange="groupRulesBy(value)">
                        <option value="default" selected="selected">Default</option>
                        <option value="severity">Severity</option>
                        <option value="result">Result</option>
                        <option disabled="disabled">──────────</option>
                        <xsl:call-template name="get-all-references">
                            <xsl:with-param name="benchmark" select="$benchmark"/>
                        </xsl:call-template>
                    </select>
                </div>
            </div>
        </div>

        <table class="treetable table table-bordered">
            <thead>
                <tr>
                    <th>Title</th>
                    <th style="width: 120px; text-align: center">Severity</th>
                    <th style="width: 120px; text-align: center">Result</th>
                </tr>
            </thead>
            <tbody>
                <xsl:variable name="failed_rule_results" select="$testresult/cdf:rule-result[cdf:result/text() = 'fail']"/>
                <xsl:variable name="error_rule_results" select="$testresult/cdf:rule-result[cdf:result/text() = 'error']"/>
                <xsl:variable name="unknown_rule_results" select="$testresult/cdf:rule-result[cdf:result/text() = 'unknown']"/>
                <xsl:variable name="notchecked_rule_results" select="$testresult/cdf:rule-result[cdf:result/text() = 'notchecked']"/>
                <xsl:variable name="notselected_rule_results" select="$testresult/cdf:rule-result[cdf:result/text() = 'notselected']"/>

                <xsl:call-template name="rule-overview-inner-node">
                    <xsl:with-param name="testresult" select="$testresult"/>
                    <xsl:with-param name="item" select="$benchmark"/>
                    <xsl:with-param name="profile" select="$profile"/>
                    <xsl:with-param name="indent" select="0"/>

                    <xsl:with-param name="failed_rule_results" select="$failed_rule_results"/>
                    <xsl:with-param name="error_rule_results" select="$error_rule_results"/>
                    <xsl:with-param name="unknown_rule_results" select="$unknown_rule_results"/>
                    <xsl:with-param name="notchecked_rule_results" select="$notchecked_rule_results"/>
                    <xsl:with-param name="notselected_rule_results" select="$notselected_rule_results"/>
                </xsl:call-template>
            </tbody>
        </table>
    </div>
</xsl:template>

<xsl:template name="check-system-details-oval5">
    <xsl:param name="check"/>
    <xsl:param name="oval-tmpl"/>
    <xsl:param name="result"/>

    <xsl:variable name="filename">
        <xsl:choose>
            <xsl:when test='contains($oval-tmpl, "%")'><xsl:value-of select='concat(substring-before($oval-tmpl, "%"), $check/cdf:check-content-ref/@href, substring-after($oval-tmpl, "%"))'/></xsl:when>
            <xsl:otherwise><xsl:value-of select='$oval-tmpl'/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="arf_results" select="(/arf:asset-report-collection/arf:reports/arf:report/arf:content/ovalres:oval_results)[1]"/>

    <xsl:variable name="details">
        <xsl:if test="$filename != ''">
            <xsl:apply-templates select="document($filename)/ovalres:oval_results" mode="brief">
                <xsl:with-param name='definition-id' select='$check/cdf:check-content-ref/@name'/>
                <xsl:with-param name='result' select='$result'/>
            </xsl:apply-templates>
        </xsl:if>

        <!-- This is a very pragmatic solution to solve our users problem,
             it is not guaranteed to do the right thing in all cases but
             it does the right thing with ARFs generated from openscap.

             potential problem:

             ARF has tons of different assets and results in it
               - this XSLT will source OVAL results that may or may
                 not be related to that particular report

               - there is nothing in the ARF to help us map OVAL results
                 to XCCDF results, we have to guess!

                 (You would think that check-content-ref/@href would help
                  us locate the arf:report with the OVAL results but 370-1
                  requirement makes the @href useless)

             I believe the benefits greatly outweigh the drawbacks in this
             case and the problem outlined will be encountered by a very
             small group of users. Still, this needs to be fixed in future
             versions!
        -->
        <xsl:apply-templates select="$arf_results" mode="brief">
            <xsl:with-param name='definition-id' select='$check/cdf:check-content-ref/@name'/>
            <xsl:with-param name='result' select='$result'/>
        </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="normalize-space($details)">
        <xsl:variable name="details_origin">
            <xsl:choose>
                <xsl:when test="$filename != ''">file '<xsl:value-of select="$filename"/>'</xsl:when>
                <xsl:otherwise>arf:report with id='<xsl:value-of select="$arf_results/parent::arf:content/parent::arf:report/@id"/>'</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <span class="label label-default"><abbr title="OVAL details taken from {$details_origin}">OVAL test results details</abbr></span>
        <div class="panel panel-default">
            <div class="panel-body">
                <xsl:copy-of select="$details"/>
            </div>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template name="check-system-details-sce">
    <xsl:param name="check"/>
    <xsl:param name="sce-tmpl"/>

    <xsl:choose>
        <xsl:when test="$check/cdf:check-import[@import-name = 'stdout']/text() or $check/cdf:check-import[@import-name = 'stderr']/text()">
            <xsl:if test="$check/cdf:check-import[@import-name = 'stdout']/text()">
                <span class="label label-default"><abbr title="Script Check Engine stdout taken from check-import">SCE stdout</abbr></span>
                <pre><code>
                    <xsl:value-of select="$check/cdf:check-import[@import-name = 'stdout']/text()"/>
                </code></pre>
            </xsl:if>
            <xsl:if test="$check/cdf:check-import[@import-name = 'stderr']/text()">
                <span class="label label-default"><abbr title="Script Check Engine stderr taken from check-import">SCE stderr</abbr></span>
                <pre><code>
                    <xsl:value-of select="$check/cdf:check-import[@import-name = 'stderr']/text()"/>
                </code></pre>
            </xsl:if>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="filename">
                <xsl:choose>
                    <xsl:when test='contains($sce-tmpl, "%")'><xsl:value-of select='concat(substring-before($sce-tmpl, "%"), $check/cdf:check-content-ref/@href, substring-after($sce-tmpl, "%"))'/></xsl:when>
                    <xsl:otherwise><xsl:value-of select='$sce-tmpl'/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:if test="$filename != ''">
                <xsl:variable name="stdout" select="document($filename)/sceres:sce_results/sceres:stdout/text()"/>
                <xsl:variable name="stderr" select="document($filename)/sceres:sce_results/sceres:stderr/text()"/>

                <xsl:if test="normalize-space($stdout)">
                    <span class="label label-default"><abbr title="Script Check Engine stdout taken from '{$filename}'">SCE stdout</abbr></span>
                    <pre><code>
                        <xsl:copy-of select="$stdout"/>
                    </code></pre>
                </xsl:if>
                <xsl:if test="normalize-space($stderr)">
                    <span class="label label-default"><abbr title="Script Check Engine stderr taken from '{$filename}'">SCE stderr</abbr></span>
                    <pre><code>
                        <xsl:copy-of select="$stderr"/>
                    </code></pre>
                </xsl:if>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="check-system-details">
    <xsl:param name="check"/>
    <xsl:param name="oval-tmpl"/>
    <xsl:param name="sce-tmpl"/>
    <xsl:param name="result"/>

    <xsl:choose>
        <xsl:when test="$check/@system = 'http://oval.mitre.org/XMLSchema/oval-definitions-5'">
            <xsl:call-template name="check-system-details-oval5">
                <xsl:with-param name="check" select="$check"/>
                <xsl:with-param name="oval-tmpl" select="$oval-tmpl"/>
                <xsl:with-param name="result" select="$result"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$check/@system = 'http://open-scap.org/page/SCE'">
            <xsl:call-template name="check-system-details-sce">
                <xsl:with-param name="check" select="$check"/>
                <xsl:with-param name="sce-tmpl" select="$sce-tmpl"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
    </xsl:choose>

</xsl:template>


<xsl:template name="result-details-leaf-table">
    <xsl:param name="item"/>
    <xsl:param name="testresult"/>
    <xsl:param name="profile"/>
    <xsl:param name="result"/>

    <table class="table table-striped table-bordered">
        <tbody>
            <tr><td class="col-md-3">Rule ID</td><td class="rule-id col-md-9"><xsl:value-of select="$item/@id"/></td></tr>
            <tr><td>Result</td>
            <td class="rule-result rule-result-{$result}">
                <xsl:variable name="result_tooltip">
                    <xsl:call-template name="rule-result-tooltip">
                        <xsl:with-param name="ruleresult" select="$result"/>
                    </xsl:call-template>
                </xsl:variable>
                <div>
                    <abbr title="{$result_tooltip}"><xsl:value-of select="$result"/></abbr>
                </div>
            </td></tr>
            <tr>
                <td>Multi-check rule</td>
                <td>
                    <xsl:choose>
                        <xsl:when test="cdf:check[@multi-check='true']">yes</xsl:when>
                        <xsl:otherwise>no</xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
            <xsl:if test="cdf:check[@system='http://oval.mitre.org/XMLSchema/oval-definitions-5']">
                <tr>
                    <td>OVAL Definition ID</td>
                    <td>
                        <xsl:value-of select="cdf:check/cdf:check-content-ref/@name" />
                    </td>
                </tr>
            </xsl:if>
            <tr><td>Time</td><td><xsl:value-of select="@time"/></td></tr>
            <tr>
                <td>Severity</td>
                <td>
                    <xsl:call-template name="item-severity">
                        <xsl:with-param name="item" select="." />
                        <xsl:with-param name="profile" select="$profile" />
                    </xsl:call-template>
                </td>
            </tr>
            <tr><td>Identifiers and References</td><td class="identifiers">
                <!-- XCCDF 1.2 spec says that idents in rule-result should be copied from
                    the Rule itself. That means that we can just use the same code as guide
                    and just use idents from Rule. -->
                <xsl:call-template name="item-idents-refs">
                    <xsl:with-param name="item" select="$item"/>
                </xsl:call-template>
            </td></tr>
            <xsl:if test="cdf:override">
                <tr><td colspan="2">
                    <xsl:for-each select="cdf:override">
                        <xsl:variable name="old-result" select="cdf:old-result/text()"/>

                        <div class="alert alert-warning waiver">
                            This rule has been waived by <strong><xsl:value-of select="@authority"/></strong> at <strong><xsl:value-of select="@date"/></strong>.
                            <blockquote>
                                <xsl:value-of select="cdf:remark/text()"/>
                            </blockquote>
                            <small>
                                The previous result was <span class="rule-result rule-result-{$old-result}">&#160;<xsl:value-of select="$old-result"/>&#160;</span>.
                            </small>
                        </div>
                    </xsl:for-each>
                </td></tr>
            </xsl:if>
            <xsl:if test="$item/cdf:description">
                <tr><td>Description</td><td><div class="description">
                        <xsl:apply-templates mode="sub-testresult" select="$item/cdf:description">
                            <xsl:with-param name="testresult" select="$testresult"/>
                            <xsl:with-param name="benchmark" select="$item/ancestor::cdf:Benchmark"/>
                            <xsl:with-param name="profile" select="$profile"/>
                        </xsl:apply-templates>
                </div></td></tr>
            </xsl:if>
            <xsl:if test="$item/cdf:rationale">
                <tr><td>Rationale</td><td><div class="rationale">
                        <xsl:apply-templates mode="sub-testresult" select="$item/cdf:rationale">
                            <xsl:with-param name="testresult" select="$testresult"/>
                            <xsl:with-param name="benchmark" select="$item/ancestor::cdf:Benchmark"/>
                            <xsl:with-param name="profile" select="$profile"/>
                        </xsl:apply-templates>
                </div></td></tr>
            </xsl:if>
            <xsl:if test="count($profile/cdf:select[@idref=$item/@id]/cdf:remark) > 0">
                <tr><td>Remarks</td><td class="remarks">
                    <xsl:for-each select="$profile/cdf:select[@idref=$item/@id]/cdf:remark">
                        <blockquote class="small">
                            <xsl:value-of select="text()" />
                        </blockquote>
                </xsl:for-each>
                </td></tr>
            </xsl:if>
            <xsl:if test="$item/cdf:warning">
                <tr><td>Warnings</td><td>
                    <xsl:for-each select="$item/cdf:warning">
                        <div class="panel panel-warning">
                            <div class="panel-heading">
                                <span class="label label-warning">warning</span>&#160;
                                <xsl:apply-templates mode="sub-testresult" select=".">
                                    <xsl:with-param name="benchmark" select="$item/ancestor::cdf:Benchmark"/>
                                    <xsl:with-param name="profile" select="$profile"/>
                                </xsl:apply-templates>
                            </div>
                        </div>
                    </xsl:for-each>
                </td></tr>
            </xsl:if>
            <xsl:if test="cdf:message">
                <tr><td colspan="2"><div class="evaluation-messages">
                    <span class="label label-default"><abbr title="Messages taken from rule-result">Evaluation messages</abbr></span>
                    <div class="panel panel-default">
                        <div class="panel-body">
                            <xsl:for-each select="cdf:message">
                                <xsl:if test="./@severity">
                                    <span class="label label-primary"><xsl:value-of select="./@severity"/></span>&#160;
                                </xsl:if>
                                <pre><xsl:apply-templates mode="sub-testresult" select=".">
                                    <xsl:with-param name="benchmark" select="$item/ancestor::cdf:Benchmark"/>
                                    <xsl:with-param name="profile" select="$profile"/>
                                </xsl:apply-templates></pre>
                            </xsl:for-each>
                        </div>
                    </div>
                </div></td></tr>
            </xsl:if>
            <xsl:if test="$result = 'fail' or $result = 'error' or $result = 'unknown'">
                <xsl:for-each select="$item/cdf:fixtext">
                    <tr><td colspan="2"><div class="remediation-description">
                        <xsl:call-template name="show-fixtext">
                            <xsl:with-param name="fixtext" select="."/>
                            <xsl:with-param name="testresult" select="$testresult"/>
                            <xsl:with-param name="benchmark" select="$item/ancestor::cdf:Benchmark"/>
                            <xsl:with-param name="profile" select="$profile"/>
                        </xsl:call-template>
                    </div></td></tr>
                </xsl:for-each>
                <xsl:for-each select="$item/cdf:fix">
                    <tr class="noprint"><td colspan="2"><div class="remediation">
                        <xsl:call-template name="show-fix">
                            <xsl:with-param name="fix" select="."/>
                            <xsl:with-param name="testresult" select="$testresult"/>
                            <xsl:with-param name="benchmark" select="$item/ancestor::cdf:Benchmark"/>
                            <xsl:with-param name="profile" select="$profile"/>
                        </xsl:call-template>
                    </div></td></tr>
                </xsl:for-each>
            </xsl:if>
        </tbody>
    </table>
</xsl:template>

<xsl:template name="result-details-leaf">
    <xsl:param name="testresult"/>
    <xsl:param name="item"/>
    <xsl:param name="profile"/>

    <xsl:variable name="ruleresult" select="key('testresult_ruleresults', concat($testresult/@id, '|', $item/@id))"/>
    <xsl:for-each select="$ruleresult">
        <xsl:variable name="result" select="cdf:result/text()"/>
        <xsl:if test="$result != 'notselected'">
            <div class="panel panel-default rule-detail rule-detail-{$result} rule-detail-id-{$item/@id}" id="rule-detail-{generate-id(.)}">
                <div class="keywords sr-only">
                    <xsl:comment>This allows OpenSCAP JS to search the report rules</xsl:comment>
                    <xsl:call-template name="item-title">
                        <xsl:with-param name="item" select="$item"/>
                        <xsl:with-param name="testresult" select="$testresult"/>
                        <xsl:with-param name="profile" select="$profile"/>
                    </xsl:call-template>
                    <xsl:value-of select="concat($item/@id, ' ')"/>
                    <xsl:value-of select="@severity"/>
                    <xsl:for-each select="cdf:ident">
                        <xsl:value-of select="concat(text(), ' ')"/>
                    </xsl:for-each>
                    <xsl:for-each select="cdf:reference">
                        <xsl:value-of select="concat(text(), ' ')"/>
                    </xsl:for-each>
                </div>
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <xsl:call-template name="item-title">
                            <xsl:with-param name="item" select="$item"/>
                            <xsl:with-param name="testresult" select="$testresult"/>
                            <xsl:with-param name="profile" select="$profile"/>
                        </xsl:call-template>
                    </h3>
                </div>
                <div class="panel-body">
                    <xsl:call-template name="result-details-leaf-table">
                            <xsl:with-param name="item" select="$item"/>
                            <xsl:with-param name="testresult" select="$testresult"/>
                            <xsl:with-param name="profile" select="$profile"/>
                            <xsl:with-param name="result" select="$result"/>
                    </xsl:call-template>
                    <xsl:variable name="check_system_details_ret">
                        <xsl:call-template name="check-system-details">
                            <xsl:with-param name="check" select="cdf:check"/>
                            <xsl:with-param name="oval-tmpl" select="$oval-tmpl"/>
                            <xsl:with-param name="sce-tmpl" select="$sce-tmpl"/>
                            <xsl:with-param name="result" select="$result"/>
                        </xsl:call-template>
                    </xsl:variable>

                    <xsl:if test="normalize-space($check_system_details_ret)">
                        <div class="check-system-details">
                            <xsl:copy-of select="$check_system_details_ret"/>
                        </div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:for-each>
</xsl:template>

<xsl:template name="result-details-inner-node">
    <xsl:param name="testresult"/>
    <xsl:param name="item"/>
    <xsl:param name="profile"/>

    <xsl:for-each select="$item/cdf:Group">
        <xsl:call-template name="result-details-inner-node">
            <xsl:with-param name="testresult" select="$testresult"/>
            <xsl:with-param name="item" select="."/>
            <xsl:with-param name="profile" select="$profile"/>
        </xsl:call-template>
    </xsl:for-each>

    <xsl:for-each select="$item/cdf:Rule">
        <xsl:call-template name="result-details-leaf">
            <xsl:with-param name="testresult" select="$testresult"/>
            <xsl:with-param name="item" select="."/>
            <xsl:with-param name="profile" select="$profile"/>
        </xsl:call-template>
    </xsl:for-each>
</xsl:template>

<xsl:template name="result-details">
    <xsl:param name="testresult"/>
    <xsl:param name="benchmark"/>
    <xsl:param name="profile"/>

    <div class="js-only hidden-print">
        <button type="button" class="btn btn-info" onclick="return toggleResultDetails(this)">Show all result details</button>
    </div>
    <div id="result-details">
        <h2>Result Details</h2>

        <xsl:call-template name="result-details-inner-node">
            <xsl:with-param name="testresult" select="$testresult"/>
            <xsl:with-param name="item" select="$benchmark"/>
            <xsl:with-param name="profile" select="$profile"/>
        </xsl:call-template>
        <a href="#result-details" class="btn btn-info noprint">Scroll back to the first rule</a>
    </div>
</xsl:template>

<xsl:template name="generate-report">
    <xsl:param name="testresult"/>
    <xsl:param name="benchmark"/>

    <xsl:variable name="profile" select="$benchmark/cdf:Profile[@id = $testresult/cdf:profile/@idref]"/>

    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
    <html lang="en">
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title><xsl:value-of select="$testresult/@id"/> | OpenSCAP Evaluation Report</title>

        <style><xsl:call-template name="css-sources"/></style>
        <script><xsl:call-template name="js-sources"/></script>
    </head>

    <body>
    <xsl:call-template name="xccdf-report-header"/>

    <div class="container"><div id="content">
        <xsl:call-template name="introduction">
            <xsl:with-param name="benchmark" select="$benchmark"/>
            <xsl:with-param name="profile" select="$profile"/>
        </xsl:call-template>
        <xsl:call-template name="characteristics">
            <xsl:with-param name="testresult" select="$testresult"/>
            <xsl:with-param name="benchmark" select="$benchmark"/>
            <xsl:with-param name="profile" select="$profile"/>
        </xsl:call-template>
        <xsl:call-template name="compliance-and-scoring">
            <xsl:with-param name="testresult" select="$testresult"/>
            <xsl:with-param name="benchmark" select="$benchmark"/>
            <xsl:with-param name="profile" select="$profile"/>
        </xsl:call-template>
        <xsl:call-template name="rule-overview">
            <xsl:with-param name="testresult" select="$testresult"/>
            <xsl:with-param name="benchmark" select="$benchmark"/>
            <xsl:with-param name="profile" select="$profile"/>
        </xsl:call-template>
        <xsl:call-template name="result-details">
            <xsl:with-param name="testresult" select="$testresult"/>
            <xsl:with-param name="benchmark" select="$benchmark"/>
            <xsl:with-param name="profile" select="$profile"/>
        </xsl:call-template>
        <xsl:call-template name="rear-matter">
            <xsl:with-param name="benchmark" select="$benchmark"/>
            <xsl:with-param name="profile" select="$profile"/>
        </xsl:call-template>
    </div></div>

    <xsl:call-template name="xccdf-report-footer"/>

    </body>
    </html>
</xsl:template>

</xsl:stylesheet>
