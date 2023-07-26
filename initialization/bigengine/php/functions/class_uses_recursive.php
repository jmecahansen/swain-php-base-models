<?php
    // enforce strict types
    declare(strict_types = 1);

    /**
     * class_uses_recursive
     * @author Julio María Meca Hansen <jmecahansen@gmail.com>
     */

    if (!function_exists("class_uses_recursive")) {
        /**
         * returns all traits used by a given class
         * @param string $class the class
         * @param bool $autoload whether to autoload the class or not
         * @return array all traits used by the given class
         * @example $traits = class_uses_recursive("foo");
         * @example $traits = class_uses_recursive("foo", false);
         * @author Julio María Meca Hansen <jmecahansen@gmail.com>
         */
        function class_uses_recursive(string $class, bool $autoload = true): array {
            $output = !empty($traits = class_uses($class, $autoload)) ? $traits : [];

            do {
                if (!empty($traits = class_uses($class, $autoload))) {
                    $output = array_merge($output, $traits);
                }
            } while ($class = get_parent_class($class));

            return array_unique($output);
        }
    }