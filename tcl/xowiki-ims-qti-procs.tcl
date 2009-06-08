::xo::library doc {

    IMS QTI Support for XoWiki

    @creation-date 2006-04-10
    @author Gustaf Neumann
    @cvs-id $Id: xowiki-www-procs.tcl,v 1.232 2009/05/08 09:12:15 gustafn Exp $
}

::xo::library require ../../ims-qti/tcl/ims-qti-procs
::xo::library require ../../xowiki/tcl/xowiki-procs
::xo::library require ../../xowf/tcl/test-item-procs

namespace eval ::xowiki::ims {}
namespace eval ::xowiki::ims::qti {

    Class test_item

    test_item instproc pretty_value {v} {
        util_user_message -message "QTI"
        util_user_message -html -message "<PRE> [my serialize] </PRE>"
        append output [next]
        append output "<pre>"
        append output [ad_quotehtml [my as_qti_xml]]
        append output "</pre>"
    }

    test_item instproc as_qti_xml {} {
        ::ims::qti::Item create i -identifier [self]

        i set tmp [self]
        
        if {[[self]::interaction set multiple] eq true} {
            i set cardinality "multiple"
        } else {
            i set cardinality "single"
        }

        i proc render_responseDeclaration {} {
            ::ims::qti::responseDeclaration -identifier "RESPONSE" -cardinality "[my set cardinality]" -baseType "identifier" {
                    ::ims::qti::correctResponse { 
                        foreach c [[my set tmp]::interaction info children] {
                            if {[Object isobject ${c}::correct]} {
                                # Multiple and single choice quesitions
                                # behave different here
                                if {[${c}::correct value] eq "t" || [${c}::correct value] eq "[${c} name]"} {
                                    ::ims::qti::value {
                                        ::ims::qti::t "[${c} id]"
                                    }
                                }
                            }
                        }
                    }
            }
        }

        i proc render_outcomeDeclaration {} {
            ::ims::qti::outcomeDeclaration -identifier "SCORE" -cardinality "single" -baseType "integer" {
                    ::ims::qti::correctResponse { 
                        foreach c [[my set tmp]::interaction info children] {
                            if {[Object isobject ${c}::correct] && [${c}::correct value] eq t} {
                                ::ims::qti::value {
                                    ::ims::qti::t "[${c} id]"
                                }
                            }
                        }
                    }
            }
        }

        i proc render_itemBody {} {
            ::ims::qti::itemBody {
                ::ims::qti::choiceInteraction -responseIdentifier "??" -shuffle false -maxChoices 0 {
                    ::ims::qti::prompt {
                        ::ims::qti::t "[[my set tmp]::interaction::text value]"
                    }
                    foreach c [[my set tmp]::interaction info children] {
                        if {[Object isobject ${c}::text]} {
                            ::ims::qti::simpleChoice -identifier "[${c} id]" {
                                ::ims::qti::t "[${c}::text value]"
                            }
                        }
                    }
                }
            }
        }

        i render

    }


    ::xowiki::formfield::test_item instmixin ::xowiki::ims::qti::test_item 
}

