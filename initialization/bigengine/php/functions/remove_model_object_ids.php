<?php
    // enforce strict types
    declare(strict_types = 1);

    /**
     * remove_model_object_ids
     * @author Julio María Meca Hansen <jmecahansen@gmail.com>
     */

    if (!function_exists("remove_model_object_ids")) {
        /**
         * remove the identifier for a given (model) object and its children
         * @param object $object the object
         * @example $result = remove_model_object_ids($foo);
         * @author Julio María Meca Hansen <jmecahansen@gmail.com>
         */
        function remove_model_object_ids(object &$object): void {
            if (method_exists($object, "removeId")) {
                $object->removeId();

                if (method_exists($object, "getObjectKeys")) {
                    foreach ($object->getObjectKeys() as $key) {
                        remove_model_object_ids($object->properties[$key]);
                    }
                }
            }
        }
    }