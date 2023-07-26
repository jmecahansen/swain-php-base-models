<?php
    // enforce strict types
    declare(strict_types = 1);

    /**
     * get_model_namespace
     * @author Julio María Meca Hansen <jmecahansen@gmail.com>
     */

    if (!function_exists("get_model_namespace")) {
        /**
         * returns the namespace for a given input model object
         * @param object $input the input model object
         * @param int $trim the number of namespace elements to trim (optional, no trimming by default)
         * @return string the namespace for the given input model object
         * @example $namespace = get_model_namespace($foo);
         * @example $namespace = get_model_namespace($foo, 2);
         * @author Julio María Meca Hansen <jmecahansen@gmail.com>
         */
        function get_model_namespace(object $input, int $trim = 0): string {
            $output = array_slice(explode("\\", $input::class), 0, -1);

            if ($trim > 0) {
                $output = array_slice($output, 0, -$trim);
            }

            return implode("\\", $output);
        }
    }