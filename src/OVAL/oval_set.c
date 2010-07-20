/**
 * @file oval_set.c
 * \brief Open Vulnerability and Assessment Language
 *
 * See more details at http://oval.mitre.org/
 */

/*
 * Copyright 2009-2010 Red Hat Inc., Durham, North Carolina.
 * All Rights Reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Authors:
 *      "David Niemoller" <David.Niemoller@g2-inc.com>
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "oval_definitions_impl.h"
#include "oval_collection_impl.h"
#include "oval_agent_api_impl.h"
#include "common/util.h"
#include "common/debug_priv.h"

typedef struct oval_setobject {
	struct oval_definition_model *model;
	oval_setobject_type_t type;
	oval_setobject_operation_t operation;
	void *extension;
} oval_set_t;

typedef struct oval_set_AGGREGATE {
	struct oval_collection *subsets;	/*type==OVAL_SET_AGGREGATE; */
} oval_set_AGGREGATE_t;

typedef struct oval_set_COLLECTIVE {
	struct oval_collection *objects;	//type==OVAL_SET_COLLECTIVE;
	struct oval_collection *filters;	//type==OVAL_SET_COLLECTIVE;
} oval_set_COLLECTIVE_t;

bool oval_setobject_iterator_has_more(struct oval_setobject_iterator *oc_set)
{
	return oval_collection_iterator_has_more((struct oval_iterator *)
						 oc_set);
}

struct oval_setobject *oval_setobject_iterator_next(struct oval_setobject_iterator *oc_set)
{
	return (struct oval_setobject *)
	    oval_collection_iterator_next((struct oval_iterator *)oc_set);
}

void oval_setobject_iterator_free(struct oval_setobject_iterator *oc_set)
{
	oval_collection_iterator_free((struct oval_iterator *)oc_set);
}

oval_setobject_type_t oval_setobject_get_type(struct oval_setobject *set)
{
	__attribute__nonnull__(set);

	return (set)->type;
}

oval_setobject_operation_t oval_setobject_get_operation(struct oval_setobject * set)
{
	__attribute__nonnull__(set);

	return ((struct oval_setobject *)set)->operation;
}

struct oval_setobject_iterator *oval_setobject_get_subsets(struct oval_setobject *set)
{
	__attribute__nonnull__(set);

	struct oval_setobject_iterator *subsets = NULL;
	if (set->type == OVAL_SET_AGGREGATE) {
		struct oval_set_AGGREGATE *aggregate = (struct oval_set_AGGREGATE *)set->extension;
		subsets = (struct oval_setobject_iterator *)
		    oval_collection_iterator(aggregate->subsets);
	}
	return subsets;
}

struct oval_object_iterator *oval_setobject_get_objects(struct oval_setobject *set)
{
	__attribute__nonnull__(set);

	/* type == OVAL_SET_COLLECTIVE; */
	struct oval_object_iterator *objects = NULL;
	if (set->type == OVAL_SET_COLLECTIVE) {
		struct oval_set_COLLECTIVE *collective = (struct oval_set_COLLECTIVE *)set->extension;
		objects = (struct oval_object_iterator *)
		    oval_collection_iterator(collective->objects);
	}
	return objects;
}

struct oval_state_iterator *oval_setobject_get_filters(struct oval_setobject *set)
{
	__attribute__nonnull__(set);

	/* type == OVAL_SET_COLLECTIVE; */
	struct oval_state_iterator *filters = NULL;
	if (set->type == OVAL_SET_COLLECTIVE) {
		struct oval_set_COLLECTIVE *collective = (struct oval_set_COLLECTIVE *)set->extension;
		filters = (struct oval_state_iterator *)
		    oval_collection_iterator(collective->filters);
	}
	return filters;
}

struct oval_setobject *oval_setobject_new(struct oval_definition_model *model)
{
	oval_set_t *set = (oval_set_t *) oscap_alloc(sizeof(oval_set_t));
	if (set == NULL)
		return NULL;

	set->operation = OVAL_SET_OPERATION_UNKNOWN;
	set->type = OVAL_SET_UNKNOWN;
	set->extension = NULL;
	set->model = model;
	return set;
}

bool oval_setobject_is_valid(struct oval_setobject * set_object)
{
	bool is_valid = true;
	oval_setobject_type_t type;

	if (set_object == NULL) {
                oscap_dlprintf(DBG_W, "Argument is not valid: NULL.\n");
		return false;
        }

	type = oval_setobject_get_type(set_object);
	switch (type) {
	case OVAL_SET_AGGREGATE:
		{
			struct oval_setobject_iterator *subsets_itr;

			subsets_itr = oval_setobject_get_subsets(set_object);
			while (oval_setobject_iterator_has_more(subsets_itr)) {
				struct oval_setobject *subset;

				subset = oval_setobject_iterator_next(subsets_itr);
				if (oval_setobject_is_valid(subset) != true) {
					is_valid = false;
					break;
				}
			}
			oval_setobject_iterator_free(subsets_itr);
			if (is_valid != true)
				return false;
		}
		break;
	case OVAL_SET_COLLECTIVE:
		{
			struct oval_object_iterator *objects_itr;
			struct oval_state_iterator *filters_itr;

			objects_itr = oval_setobject_get_objects(set_object);
			while (oval_object_iterator_has_more(objects_itr)) {
				struct oval_object *object;

				object = oval_object_iterator_next(objects_itr);
				if (oval_object_is_valid(object) != true) {
					is_valid = false;
					break;
				}
			}
			oval_object_iterator_free(objects_itr);
			if (is_valid != true)
				return false;

			filters_itr = oval_setobject_get_filters(set_object);
			while (oval_state_iterator_has_more(filters_itr)) {
				struct oval_state *state;

				state = oval_state_iterator_next(filters_itr);
				if (oval_state_is_valid(state) != true) {
					is_valid = false;
					break;
				}
			}
			oval_state_iterator_free(filters_itr);
			if (is_valid != true)
				return false;
		}
		break;
	default:
                oscap_dlprintf(DBG_W, "Argument is not valid: wrong setobject type: %d.\n", type);
		return false;
	}

	return true;
}

bool oval_setobject_is_locked(struct oval_setobject * setobject)
{
	__attribute__nonnull__(setobject);

	return oval_definition_model_is_locked(setobject->model);
}

struct oval_setobject *oval_setobject_clone
    (struct oval_definition_model *new_model, struct oval_setobject *old_setobject) {
	struct oval_setobject *new_setobject = oval_setobject_new(new_model);
	oval_setobject_type_t type = oval_setobject_get_type(old_setobject);
	oval_setobject_set_type(new_setobject, type);
	oval_setobject_operation_t operation = oval_setobject_get_operation(old_setobject);
	oval_setobject_set_operation(new_setobject, operation);
	switch (type) {
	case OVAL_SET_COLLECTIVE:{
			struct oval_state_iterator *filters = oval_setobject_get_filters(old_setobject);
			while (oval_state_iterator_has_more(filters)) {
				struct oval_state *filter = oval_state_iterator_next(filters);
				oval_setobject_add_filter(new_setobject, oval_state_clone(new_model, filter));
			}
			oval_state_iterator_free(filters);
			struct oval_object_iterator *objects = oval_setobject_get_objects(old_setobject);
			while (oval_object_iterator_has_more(objects)) {
				struct oval_object *object = oval_object_iterator_next(objects);
				oval_setobject_add_object(new_setobject, oval_object_clone(new_model, object));
			}
			oval_object_iterator_free(objects);

		} break;
	case OVAL_SET_AGGREGATE:{
			struct oval_setobject_iterator *subsets = oval_setobject_get_subsets(old_setobject);
			while (oval_setobject_iterator_has_more(subsets)) {
				struct oval_setobject *subset = oval_setobject_iterator_next(subsets);
				oval_setobject_add_subset(new_setobject, oval_setobject_clone(new_model, subset));
			}
			oval_setobject_iterator_free(subsets);
		} break;
	default:
		/*NOOP*/;
	}
	return new_setobject;
}

void oval_setobject_free(struct oval_setobject *set)
{
	__attribute__nonnull__(set);

	switch (set->type) {
	case OVAL_SET_AGGREGATE:{
			oval_set_AGGREGATE_t *aggregate = (oval_set_AGGREGATE_t *) set->extension;
			oval_collection_free_items(aggregate->subsets, (oscap_destruct_func) oval_setobject_free);
			aggregate->subsets = NULL;
			oscap_free(set->extension);
			set->extension = NULL;
		}
		break;
	case OVAL_SET_COLLECTIVE:{
			oval_set_COLLECTIVE_t *collective = (oval_set_COLLECTIVE_t *) set->extension;
			//States and objects are shared and should not be deleted here.
			oval_collection_free_items(collective->filters, NULL);
			oval_collection_free_items(collective->objects, NULL);
			collective->filters = NULL;
			collective->objects = NULL;
			oscap_free(set->extension);
			set->extension = NULL;
		}
		break;
	case OVAL_SET_UNKNOWN:
		break;
	}
	oscap_free(set);
}

void oval_setobject_set_type(struct oval_setobject *set, oval_setobject_type_t type)
{
	if (set && !oval_setobject_is_locked(set)) {
		set->type = type;
		switch (type) {
		case OVAL_SET_AGGREGATE:{
				oval_set_AGGREGATE_t *aggregate =
				    (oval_set_AGGREGATE_t *) (set->extension =
							      oscap_alloc(sizeof(oval_set_AGGREGATE_t)));
				aggregate->subsets = oval_collection_new();
			}
			break;
		case OVAL_SET_COLLECTIVE:{
				oval_set_COLLECTIVE_t *collective =
				    (oval_set_COLLECTIVE_t *) (set->extension =
							       oscap_alloc(sizeof(oval_set_COLLECTIVE_t)));
				collective->filters = oval_collection_new();
				collective->objects = oval_collection_new();
			}
			break;
		case OVAL_SET_UNKNOWN:
			break;
		}
	} else
		oscap_dlprintf(DBG_W, "Attempt to update locked content.\n");
}

void oval_setobject_set_operation(struct oval_setobject *set, oval_setobject_operation_t operation)
{
	if (set && !oval_setobject_is_locked(set)) {
		set->operation = operation;
	} else
		oscap_dlprintf(DBG_W, "Attempt to update locked content.\n");
}

void oval_setobject_add_subset(struct oval_setobject *set, struct oval_setobject *subset)
{
	if (set && !oval_setobject_is_locked(set)) {
		oval_set_AGGREGATE_t *aggregate = (oval_set_AGGREGATE_t *) set->extension;
		assert(aggregate != NULL);
		oval_collection_add(aggregate->subsets, (void *)subset);
	} else
		oscap_dlprintf(DBG_W, "Attempt to update locked content.\n");
}

void oval_setobject_add_object(struct oval_setobject *set, struct oval_object *object)
{
	if (set && !oval_setobject_is_locked(set)) {
		oval_set_COLLECTIVE_t *collective = (oval_set_COLLECTIVE_t *) set->extension;
		assert(collective != NULL);
		oval_collection_add(collective->objects, (void *)object);
	} else
		oscap_dlprintf(DBG_W, "Attempt to update locked content.\n");
}

void oval_setobject_add_filter(struct oval_setobject *set, struct oval_state *filter)
{
	if (set && !oval_setobject_is_locked(set)) {
		oval_set_COLLECTIVE_t *collective = (oval_set_COLLECTIVE_t *) set->extension;
		assert(collective != NULL);
		oval_collection_add(collective->filters, (void *)filter);
	} else
		oscap_dlprintf(DBG_W, "Attempt to update locked content.\n");
}

//typedef int (*oval_xml_tag_parser)(xmlTextReaderPtr, struct oval_parser_context*, void*);
static void oval_set_consume(struct oval_setobject *subset, void *set)
{
	oval_setobject_add_subset(set, subset);
}

struct oval_set_context {
	struct oval_parser_context *context;
	struct oval_setobject *set;
};
static void oval_consume_object_ref(char *objref, void *user)
{

	__attribute__nonnull__(user);

	struct oval_set_context *ctx = user;
	struct oval_definition_model *model = oval_parser_context_model(ctx->context);
	struct oval_object *object = oval_object_get_new(model, objref);
	oval_setobject_add_object(ctx->set, object);
}

static void oval_consume_state_ref(char *steref, void *user)
{

	__attribute__nonnull__(user);

	struct oval_set_context *ctx = user;
	struct oval_definition_model *model = oval_parser_context_model(ctx->context);
	struct oval_state *state = oval_state_get_new(model, steref);
	oval_setobject_add_filter(ctx->set, state);
}

static int _oval_set_parse_tag(xmlTextReaderPtr reader, struct oval_parser_context *context, void *user)
{
	__attribute__nonnull__(user);

	struct oval_setobject *set = (struct oval_setobject *)user;
	char *tagname = (char *)xmlTextReaderLocalName(reader);
	xmlChar *namespace = xmlTextReaderNamespaceUri(reader);
	struct oval_set_context ctx = {.context = context,.set = set };

	int return_code = 0;

	if (strcmp(tagname, "set") == 0) {
		if (set->type == OVAL_SET_UNKNOWN) {
			oval_setobject_set_type(set, OVAL_SET_AGGREGATE);
		}
		return_code = oval_set_parse_tag(reader, context, &oval_set_consume, set);
	} else {
		if (set->type == OVAL_SET_UNKNOWN) {
			oval_setobject_set_type(set, OVAL_SET_COLLECTIVE);
		}
		if (strcmp(tagname, "object_reference") == 0) {
			return_code = oval_parser_text_value(reader, context, &oval_consume_object_ref, &ctx);
		} else if (strcmp(tagname, "filter") == 0) {
			return_code = oval_parser_text_value(reader, context, &oval_consume_state_ref, &ctx);
		} else {
			oscap_dlprintf(DBG_W, "Unknown tag: <%s>, line: %d.\n", tagname,
                                      xmlTextReaderGetParserLineNumber(reader));
			return_code = oval_parser_skip_tag(reader, context);
		}
	}
	if (return_code != 1) {
		oscap_dlprintf(DBG_I, "Parsing of <%s> terminated by an error at line %d.\n", tagname,
			       xmlTextReaderGetParserLineNumber(reader));
	}
	oscap_free(tagname);
	oscap_free(namespace);
	return return_code;
}

//typedef void (*oval_set_consumer)(struct oval_set*,void*);
int oval_set_parse_tag(xmlTextReaderPtr reader,
		       struct oval_parser_context *context, oval_set_consumer consumer, void *user)
{
	__attribute__nonnull__(context);

	xmlChar *tagname = xmlTextReaderLocalName(reader);
	xmlChar *namespace = xmlTextReaderNamespaceUri(reader);
	struct oval_setobject *set = oval_setobject_new(context->definition_model);

	oval_setobject_operation_t operation = oval_set_operation_parse(reader, "set_operator",
									OVAL_SET_OPERATION_UNION);
	oval_setobject_set_operation(set, operation);

	(*consumer) (set, user);

	int return_code = oval_parser_parse_tag(reader, context, &_oval_set_parse_tag, set);

	oscap_free(tagname);
	oscap_free(namespace);
	return return_code;
}

void oval_set_to_print(struct oval_setobject *set, char *indent, int idx)
{
	char nxtindent[100];

	if (strlen(indent) > 80)
		indent = "....";

	if (idx == 0)
		snprintf(nxtindent, sizeof(nxtindent), "%sSET.", indent);
	else
		snprintf(nxtindent, sizeof(nxtindent), "%sSET[%d].", indent, idx);

	oscap_dprintf("%sOPERATOR    = %d\n", nxtindent, oval_setobject_get_operation(set));
	oscap_dprintf("%sTYPE        = %d\n", nxtindent, oval_setobject_get_type(set));

	switch (oval_setobject_get_type(set)) {
	case OVAL_SET_AGGREGATE:{
			struct oval_setobject_iterator *subsets = oval_setobject_get_subsets(set);
			int i;
			for (i = 1; oval_setobject_iterator_has_more(subsets); i++) {
				struct oval_setobject *subset = oval_setobject_iterator_next(subsets);
				oval_set_to_print(subset, nxtindent, i);
			}
			oval_setobject_iterator_free(subsets);
		} break;
	case OVAL_SET_COLLECTIVE:{
			struct oval_object_iterator *objects = oval_setobject_get_objects(set);
			int i;
			for (i = 1; oval_object_iterator_has_more(objects); i++) {
				struct oval_object *object = oval_object_iterator_next(objects);
				oval_object_to_print(object, nxtindent, i);
			}
			oval_object_iterator_free(objects);
			struct oval_state_iterator *states = oval_setobject_get_filters(set);
			for (i = 1; oval_state_iterator_has_more(states); i++) {
				struct oval_state *state = oval_state_iterator_next(states);
				oval_state_to_print(state, nxtindent, i);
			}
			oval_state_iterator_free(states);
		} break;
	case OVAL_SET_UNKNOWN:
		break;
	}
}

xmlNode *oval_set_to_dom(struct oval_setobject *set, xmlDoc * doc, xmlNode * parent) {
	xmlNs *ns_definitions = xmlSearchNsByHref(doc, parent, OVAL_DEFINITIONS_NAMESPACE);
	xmlNode *set_node = xmlNewChild(parent, ns_definitions, BAD_CAST "set", NULL);
	if (ns_definitions == NULL) {
		ns_definitions = xmlNewNs(set_node, OVAL_DEFINITIONS_NAMESPACE, NULL);
		xmlSetNs(set_node, ns_definitions);
	}

	oval_setobject_operation_t operation = oval_setobject_get_operation(set);
	if (operation != OVAL_SET_OPERATION_UNION)
		xmlNewProp(set_node, BAD_CAST "set_operator", BAD_CAST oval_set_operation_get_text(operation));

	switch (oval_setobject_get_type(set)) {
	case OVAL_SET_AGGREGATE:{
			struct oval_setobject_iterator *subsets = oval_setobject_get_subsets(set);
			while (oval_setobject_iterator_has_more(subsets)) {
				struct oval_setobject *subset = oval_setobject_iterator_next(subsets);
				oval_set_to_dom(subset, doc, set_node);
			}
			oval_setobject_iterator_free(subsets);
		} break;
	case OVAL_SET_COLLECTIVE:{
			struct oval_object_iterator *objects = oval_setobject_get_objects(set);
			while (oval_object_iterator_has_more(objects)) {
				struct oval_object *object = oval_object_iterator_next(objects);
				char *id = oval_object_get_id(object);
				xmlNewChild(set_node, ns_definitions, BAD_CAST "object_reference", BAD_CAST id);
			}
			oval_object_iterator_free(objects);
			struct oval_state_iterator *filters = oval_setobject_get_filters(set);
			while (oval_state_iterator_has_more(filters)) {
				struct oval_state *filter = oval_state_iterator_next(filters);
				char *id = oval_state_get_id(filter);
				xmlNewChild(set_node, ns_definitions, BAD_CAST "filter", BAD_CAST id);
			}
			oval_state_iterator_free(filters);
		} break;
	default:
		break;
	}

	return set_node;
}
