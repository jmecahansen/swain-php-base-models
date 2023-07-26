<?php
    // enforce strict types
    declare(strict_types = 1);

    /**
     * expand_model_object
     * @author Julio María Meca Hansen <jmecahansen@gmail.com>
     */

    if (!function_exists("expand_model_object")) {
        /**
         * expands all object properties for a given object
         * @param object $object the object
         * @example expand_model_object($foo);
         * @author Julio María Meca Hansen <jmecahansen@gmail.com>
         */
        function expand_model_object(object &$object): void {
            if (
                method_exists($object, "addContent") &&
                method_exists($object, "getContentLanguages")
            ) {
                foreach ($object->getContentLanguages() as $language => $id) {
                    $object->addContent($language, $id);
                }
            }

            if (!empty($loaders = get_model_object_loaders($object))) {
                foreach ($loaders as $method) {
                    if (method_exists($object, $method)) {
                        $object->{$method}();
                    }

                    if (method_exists($object, "getObjectKeys")) {
                        foreach ($object->getObjectKeys() as $key) {
                            expand_model_object($object->properties[$key]);
                        }
                    }
                }
            }
        }
    }