<?php
    // enforce strict types
    declare(strict_types = 1);

    /**
     * get_relative_class
     * @author Julio María Meca Hansen <jmecahansen@gmail.com>
     */

    if (!function_exists("get_relative_class")) {
        /**
         * returns the class name relative (as in A\\B) to a given target class
         * @param object $object the source class object
         * @param string $target the target class name (unqualified)
         * @return false|string the class name relative (as in A\\B) to the given target class if successful, false otherwise
         * @example $result = get_relative_class($object, "Bar");
         * @author Julio María Meca Hansen <jmecahansen@gmail.com>
         */
        function get_relative_class(object $object, string $target): false|string {
            $output = false;

            if (class_exists($class = sprintf("%s\\%s", $object::class, $target))) {
                $output = $object::class;
            } elseif (!empty($parent = get_parent_class($object))) {
                $output = get_relative_class(new $parent(), $target);
            }

            return $output;
        }
    }