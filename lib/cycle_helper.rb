# extracted from: actionpack-3.1.3/lib/action_view/helpers/text_helper.rb

module CycleHelper
  # Creates a Cycle object whose _to_s_ method cycles through elements of an
  # array every time it is called. This can be used for example, to alternate
  # classes for table rows.  You can use named cycles to allow nesting in loops.
  # Passing a Hash as the last parameter with a <tt>:name</tt> key will create a
  # named cycle. The default name for a cycle without a +:name+ key is
  # <tt>"default"</tt>. You can manually reset a cycle by calling reset_cycle
  # and passing the name of the cycle. The current cycle string can be obtained
  # anytime using the current_cycle method.
  #
  # ==== Examples
  #   # Alternate CSS classes for even and odd numbers...
  #   @items = [1,2,3,4]
  #   <table>
  #   <% @items.each do |item| %>
  #     <tr class="<%= cycle("odd", "even") -%>">
  #       <td>item</td>
  #     </tr>
  #   <% end %>
  #   </table>
  #
  #
  #   # Cycle CSS classes for rows, and text colors for values within each row
  #   @items = x = [{:first => 'Robert', :middle => 'Daniel', :last => 'James'},
  #                {:first => 'Emily', :middle => 'Shannon', :maiden => 'Pike', :last => 'Hicks'},
  #               {:first => 'June', :middle => 'Dae', :last => 'Jones'}]
  #   <% @items.each do |item| %>
  #     <tr class="<%= cycle("odd", "even", :name => "row_class") -%>">
  #       <td>
  #         <% item.values.each do |value| %>
  #           <%# Create a named cycle "colors" %>
  #           <span style="color:<%= cycle("red", "green", "blue", :name => "colors") -%>">
  #             <%= value %>
  #           </span>
  #         <% end %>
  #         <% reset_cycle("colors") %>
  #       </td>
  #    </tr>
  #  <% end %>
  def cycle(first_value, *values)
    if (values.last.instance_of? Hash)
      params = values.pop
      name = params[:name]
    else
      name = "default"
    end
    values.unshift(first_value)

    cycle = get_cycle(name)
    unless cycle && cycle.values == values
      cycle = set_cycle(name, Cycle.new(*values))
    end
    cycle.to_s
  end

  # Returns the current cycle string after a cycle has been started. Useful
  # for complex table highlighting or any other design need which requires
  # the current cycle string in more than one place.
  #
  # ==== Example
  #   # Alternate background colors
  #   @items = [1,2,3,4]
  #   <% @items.each do |item| %>
  #     <div style="background-color:<%= cycle("red","white","blue") %>">
  #       <span style="background-color:<%= current_cycle %>"><%= item %></span>
  #     </div>
  #   <% end %>
  def current_cycle(name = "default")
    cycle = get_cycle(name)
    cycle.current_value if cycle
  end

  # Resets a cycle so that it starts from the first element the next time
  # it is called. Pass in +name+ to reset a named cycle.
  #
  # ==== Example
  #   # Alternate CSS classes for even and odd numbers...
  #   @items = [[1,2,3,4], [5,6,3], [3,4,5,6,7,4]]
  #   <table>
  #   <% @items.each do |item| %>
  #     <tr class="<%= cycle("even", "odd") -%>">
  #         <% item.each do |value| %>
  #           <span style="color:<%= cycle("#333", "#666", "#999", :name => "colors") -%>">
  #             <%= value %>
  #           </span>
  #         <% end %>
  #
  #         <% reset_cycle("colors") %>
  #     </tr>
  #   <% end %>
  #   </table>
  def reset_cycle(name = "default")
    cycle = get_cycle(name)
    cycle.reset if cycle
  end

  class Cycle #:nodoc:
    attr_reader :values

    def initialize(first_value, *values)
      @values = values.unshift(first_value)
      reset
    end

    def reset
      @index = 0
    end

    def current_value
      @values[previous_index].to_s
    end

    def to_s
      value = @values[@index].to_s
      @index = next_index
      return value
    end

    private

    def next_index
      step_index(1)
    end

    def previous_index
      step_index(-1)
    end

    def step_index(n)
      (@index + n) % @values.size
    end
  end

  private
  # The cycle helpers need to store the cycles in a place that is
  # guaranteed to be reset every time a page is rendered, so it
  # uses an instance variable of ActionView::Base.
  def get_cycle(name)
    @_cycles = Hash.new unless defined?(@_cycles)
    return @_cycles[name]
  end

  def set_cycle(name, cycle_object)
    @_cycles = Hash.new unless defined?(@_cycles)
    @_cycles[name] = cycle_object
  end
end
